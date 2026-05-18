require('dotenv').config();

const express = require('express');
const cors = require('cors');
const fs = require('fs');
const path = require('path');
const admin = require('firebase-admin');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const PORT = Number(process.env.PORT || 3000);
const JWT_SECRET = process.env.JWT_SECRET || 'dacs3-local-development-secret';
const ADMIN_EMAILS = (process.env.ADMIN_EMAILS || '')
  .split(',')
  .map((value) => value.trim().toLowerCase())
  .filter(Boolean);
const STORE_FILE = path.join(__dirname, 'data', 'store.js');
const SERVICE_ACCOUNT_FILE = path.join(__dirname, 'serviceAccountKey.json');

function loadStore() {
  delete require.cache[require.resolve(STORE_FILE)];
  return require(STORE_FILE);
}

function saveStore(store) {
  const content = `module.exports = ${JSON.stringify(store, null, 2)};\n`;
  fs.writeFileSync(STORE_FILE, content, 'utf8');
}

function ensureAdminInitialized() {
  if (admin.apps.length > 0) {
    return admin.app();
  }

  const projectId = process.env.FIREBASE_PROJECT_ID || 'dacs3-7dea8';

  if (fs.existsSync(SERVICE_ACCOUNT_FILE)) {
    const serviceAccount = require(SERVICE_ACCOUNT_FILE);
    return admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
      projectId,
    });
  }

  return admin.initializeApp({
    credential: admin.credential.applicationDefault(),
    projectId,
  });
}

ensureAdminInitialized();

const app = express();
app.use(cors());
app.use(express.json());

function normalizeRole(role) {
  return role === 'admin' ? 'admin' : 'user';
}

function sanitizeUser(user) {
  return {
    uid: user.uid,
    email: user.email,
    role: normalizeRole(user.role),
    displayName: user.displayName,
    provider: user.provider || 'local',
    createdAt: user.createdAt,
  };
}

function normalizeEmail(email) {
  return String(email || '').trim().toLowerCase();
}

function createLocalToken(user) {
  return jwt.sign(
    {
      uid: user.uid,
      email: user.email,
      provider: 'local',
    },
    JWT_SECRET,
    { expiresIn: '7d' },
  );
}

function createUserRecord({ uid, email, displayName, provider, passwordHash }) {
  const normalizedEmail = normalizeEmail(email);
  return {
    uid,
    email: normalizedEmail,
    role: ADMIN_EMAILS.includes(normalizedEmail) ? 'admin' : 'user',
    displayName: String(displayName || normalizedEmail || 'User').trim(),
    provider,
    passwordHash,
    createdAt: new Date().toISOString(),
  };
}

function seedUserRole(store, decodedToken) {
  const uid = decodedToken.uid;
  const email = (decodedToken.email || '').toLowerCase();
  let user = store.users.find((item) => item.uid === uid);

  if (!user) {
    const role = ADMIN_EMAILS.includes(email) ? 'admin' : 'user';
    user = {
      uid,
      email,
      role,
      displayName: decodedToken.name || decodedToken.email || 'User',
      provider: 'google',
      createdAt: new Date().toISOString(),
    };
    store.users.push(user);
    saveStore(store);
  }

  if (user.role !== 'admin' && ADMIN_EMAILS.includes(email)) {
    user.role = 'admin';
    saveStore(store);
  }

  return user;
}

function authenticateLocalToken(token) {
  const payload = jwt.verify(token, JWT_SECRET);
  const store = loadStore();
  const user = store.users.find((item) => item.uid === payload.uid && item.provider === 'local');

  if (!user) {
    throw new Error('Local user not found.');
  }

  return { store, user, decodedToken: payload };
}

function decodeUnverifiedFirebaseToken(token) {
  const decoded = jwt.decode(token);

  if (!decoded || typeof decoded !== 'object') {
    throw new Error('Unable to decode token payload.');
  }

  if (!decoded.uid && !decoded.sub) {
    throw new Error('Token payload does not contain a user id.');
  }

  return {
    uid: decoded.uid || decoded.sub,
    email: decoded.email || '',
    name: decoded.name || decoded.email || 'User',
  };
}

async function authMiddleware(req, res, next) {
  try {
    const header = req.headers.authorization || '';
    const token = header.startsWith('Bearer ') ? header.slice(7) : null;

    if (!token) {
      return res.status(401).json({ message: 'Missing Bearer token.' });
    }

    if (token.startsWith('local:')) {
      const localAuth = authenticateLocalToken(token.slice(6));
      req.user = localAuth.user;
      req.decodedToken = localAuth.decodedToken;
      req.store = localAuth.store;
      return next();
    }

    const decodedToken = await admin.auth().verifyIdToken(token);
    const store = loadStore();
    const user = seedUserRole(store, decodedToken);

    req.user = user;
    req.decodedToken = decodedToken;
    req.store = store;
    next();
  } catch (error) {
    if (token && process.env.NODE_ENV !== 'production') {
      try {
        const decodedToken = decodeUnverifiedFirebaseToken(token);
        const store = loadStore();
        const user = seedUserRole(store, decodedToken);

        req.user = user;
        req.decodedToken = decodedToken;
        req.store = store;
        return next();
      } catch (fallbackError) {
        return res.status(401).json({
          message: 'Invalid authentication token.',
          error: fallbackError.message,
        });
      }
    }

    return res.status(401).json({ message: 'Invalid authentication token.', error: error.message });
  }
}

function requireAdmin(req, res, next) {
  if (req.user.role !== 'admin') {
    return res.status(403).json({ message: 'Admin only.' });
  }
  next();
}

function transactionBelongsToUser(transaction, user) {
  return user.role === 'admin' || transaction.userId === user.uid;
}

function budgetBelongsToUser(budget, user) {
  return user.role === 'admin' || budget.userId === user.uid;
}

function mapTransaction(item) {
  return {
    id: item.id,
    title: item.title,
    amount: item.amount,
    type: item.type,
    category: item.category,
    note: item.note || '',
    createdAt: item.createdAt,
    userId: item.userId,
    userEmail: item.userEmail || '',
    createdBy: item.createdBy || '',
  };
}

function mapBudget(item) {
  return {
    id: item.id,
    month: item.month,
    category: item.category,
    limit: item.limit,
    userId: item.userId,
  };
}

app.get('/health', (_, res) => {
  res.json({ ok: true });
});

app.post('/auth/register', async (req, res) => {
  const name = String(req.body.name || '').trim();
  const email = normalizeEmail(req.body.email);
  const password = String(req.body.password || '');

  if (!email || !email.includes('@') || password.length < 6) {
    return res.status(400).json({ message: 'Invalid registration data.' });
  }

  const store = loadStore();
  const existing = store.users.find((item) => item.email === email && item.provider === 'local');

  if (existing) {
    return res.status(409).json({ message: 'Email already in use.' });
  }

  const passwordHash = await bcrypt.hash(password, 10);
  const user = createUserRecord({
    uid: `local-${Date.now()}-${Math.random().toString(36).slice(2, 10)}`,
    email,
    displayName: name || email,
    provider: 'local',
    passwordHash,
  });

  store.users.push(user);
  saveStore(store);

  res.status(201).json({
    token: `local:${createLocalToken(user)}`,
    user: sanitizeUser(user),
  });
});

app.post('/auth/login', async (req, res) => {
  const email = normalizeEmail(req.body.email);
  const password = String(req.body.password || '');
  const store = loadStore();
  const user = store.users.find((item) => item.email === email && item.provider === 'local');

  if (!user || !user.passwordHash) {
    return res.status(401).json({ message: 'Invalid email or password.' });
  }

  const passwordMatches = await bcrypt.compare(password, user.passwordHash);

  if (!passwordMatches) {
    return res.status(401).json({ message: 'Invalid email or password.' });
  }

  res.json({
    token: `local:${createLocalToken(user)}`,
    user: sanitizeUser(user),
  });
});

app.post('/auth/forgot-password', async (req, res) => {
  const email = normalizeEmail(req.body.email);
  const store = loadStore();
  const user = store.users.find((item) => item.email === email && item.provider === 'local');

  if (!user) {
    // Không tiết lộ user có tồn tại hay không để bảo mật
    return res.json({ message: 'If the email exists, a reset link has been sent.' });
  }

  // Trong thực tế, bạn sẽ gửi email với reset link
  // Hiện tại chỉ log ra console để demo
  console.log(`Password reset requested for: ${email}`);
  console.log(`Reset link would be: http://localhost:64200/reset-password?token=${createLocalToken(user)}`);

  res.json({ message: 'If the email exists, a reset link has been sent.' });
});

app.post('/auth/reset-password', async (req, res) => {
  const { token, newPassword } = req.body;

  if (!token || !newPassword || newPassword.length < 6) {
    return res.status(400).json({ message: 'Invalid reset data.' });
  }

  try {
    const payload = jwt.verify(token.replace('local:', ''), JWT_SECRET);
    const store = loadStore();
    const user = store.users.find((item) => item.uid === payload.uid && item.provider === 'local');

    if (!user) {
      return res.status(404).json({ message: 'User not found.' });
    }

    const passwordHash = await bcrypt.hash(newPassword, 10);
    user.passwordHash = passwordHash;
    saveStore(store);

    res.json({ message: 'Password reset successfully.' });
  } catch (error) {
    return res.status(401).json({ message: 'Invalid or expired reset token.' });
  }
});

app.post('/auth/google', authMiddleware, (req, res) => {
  res.json({ user: sanitizeUser(req.user) });
});

app.get('/me', authMiddleware, (req, res) => {
  res.json(sanitizeUser(req.user));
});

app.get('/categories', authMiddleware, (req, res) => {
  res.json(req.store.categories);
});

app.get('/users', authMiddleware, requireAdmin, (req, res) => {
  res.json(req.store.users);
});

app.patch('/users/:uid/role', authMiddleware, requireAdmin, (req, res) => {
  const { uid } = req.params;
  const { role } = req.body;
  const store = loadStore();
  const user = store.users.find((item) => item.uid === uid);

  if (!user) {
    return res.status(404).json({ message: 'User not found.' });
  }

  user.role = normalizeRole(role);
  saveStore(store);
  return res.json(user);
});

app.get('/transactions', authMiddleware, (req, res) => {
  const store = loadStore();
  const items = req.user.role === 'admin'
    ? store.transactions
    : store.transactions.filter((transaction) => transaction.userId === req.user.uid);

  res.json(items.map(mapTransaction));
});

app.get('/budgets', authMiddleware, (req, res) => {
  const store = loadStore();
  const budgets = Array.isArray(store.budgets) ? store.budgets : [];
  const items = req.user.role === 'admin'
    ? budgets
    : budgets.filter((budget) => budget.userId === req.user.uid);

  res.json(items.map(mapBudget));
});

app.put('/budgets/:month/:category', authMiddleware, (req, res) => {
  const { month, category } = req.params;
  const store = loadStore();
  if (!Array.isArray(store.budgets)) {
    store.budgets = [];
  }

  const normalizedMonth = String(month || '').trim();
  const normalizedCategory = String(category || 'overall').trim().toLowerCase();
  const ownerId = req.user.uid;
  let budget = store.budgets.find(
    (item) =>
      item.month === normalizedMonth &&
      item.category === normalizedCategory &&
      budgetBelongsToUser(item, req.user)
  );

  if (!budget) {
    budget = {
      id: `${normalizedMonth}-${normalizedCategory}-${ownerId}`,
      month: normalizedMonth,
      category: normalizedCategory,
      limit: 0,
      userId: ownerId,
    };
    store.budgets.push(budget);
  }

  budget.limit = Math.max(0, Number(req.body.limit) || 0);
  saveStore(store);
  res.json(mapBudget(budget));
});

app.post('/transactions', authMiddleware, (req, res) => {
  const { title, amount, type, category, note, userId } = req.body;
  const store = loadStore();
  const ownerId = req.user.role === 'admin' && typeof userId === 'string' && userId.trim().length > 0
    ? userId.trim()
    : req.user.uid;
  const owner = store.users.find((item) => item.uid === ownerId) || req.user;

  const transaction = {
    id: `${Date.now()}-${Math.random().toString(36).slice(2, 10)}`,
    title: String(title || '').trim() || 'Untitled',
    amount: Number(amount) || 0,
    type: type === 'income' ? 'income' : 'expense',
    category: String(category || 'other').trim().toLowerCase(),
    note: String(note || '').trim(),
    createdAt: new Date().toISOString(),
    userId: owner.uid,
    userEmail: owner.email || '',
    createdBy: req.user.uid,
  };

  store.transactions.unshift(transaction);
  saveStore(store);
  res.status(201).json(mapTransaction(transaction));
});

app.put('/transactions/:id', authMiddleware, (req, res) => {
  const { id } = req.params;
  const store = loadStore();
  const transaction = store.transactions.find((item) => item.id === id);

  if (!transaction) {
    return res.status(404).json({ message: 'Transaction not found.' });
  }

  if (!transactionBelongsToUser(transaction, req.user)) {
    return res.status(403).json({ message: 'Forbidden.' });
  }

  transaction.title = String(req.body.title || transaction.title).trim();
  transaction.amount = Number(req.body.amount ?? transaction.amount) || 0;
  transaction.type = req.body.type === 'income' ? 'income' : 'expense';
  transaction.category = String(req.body.category || transaction.category).trim().toLowerCase();
  transaction.note = String(req.body.note || transaction.note).trim();
  saveStore(store);
  res.json(mapTransaction(transaction));
});

app.delete('/transactions/:id', authMiddleware, (req, res) => {
  const { id } = req.params;
  const store = loadStore();
  const index = store.transactions.findIndex((item) => item.id === id);

  if (index < 0) {
    return res.status(404).json({ message: 'Transaction not found.' });
  }

  const transaction = store.transactions[index];
  if (!transactionBelongsToUser(transaction, req.user)) {
    return res.status(403).json({ message: 'Forbidden.' });
  }

  store.transactions.splice(index, 1);
  saveStore(store);
  res.status(204).send();
});

app.listen(PORT, () => {
  console.log(`Node API running on http://localhost:${PORT}`);
});

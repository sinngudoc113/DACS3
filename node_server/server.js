require('dotenv').config();

const express = require('express');
const cors = require('cors');
const fs = require('fs');
const path = require('path');
const admin = require('firebase-admin');

const PORT = Number(process.env.PORT || 3000);
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

  if (fs.existsSync(SERVICE_ACCOUNT_FILE)) {
    const serviceAccount = require(SERVICE_ACCOUNT_FILE);
    return admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
    });
  }

  return admin.initializeApp({
    credential: admin.credential.applicationDefault(),
  });
}

ensureAdminInitialized();

const app = express();
app.use(cors());
app.use(express.json());

function normalizeRole(role) {
  return role === 'admin' ? 'admin' : 'user';
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

async function authMiddleware(req, res, next) {
  try {
    const header = req.headers.authorization || '';
    const token = header.startsWith('Bearer ') ? header.slice(7) : null;

    if (!token) {
      return res.status(401).json({ message: 'Missing Bearer token.' });
    }

    const decodedToken = await admin.auth().verifyIdToken(token);
    const store = loadStore();
    const user = seedUserRole(store, decodedToken);

    req.user = user;
    req.decodedToken = decodedToken;
    req.store = store;
    next();
  } catch (error) {
    return res.status(401).json({ message: 'Invalid Firebase token.', error: error.message });
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

app.get('/me', authMiddleware, (req, res) => {
  res.json({
    uid: req.user.uid,
    email: req.user.email,
    role: normalizeRole(req.user.role),
    displayName: req.user.displayName,
  });
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

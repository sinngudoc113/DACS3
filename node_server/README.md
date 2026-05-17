# DACS3 Node API

Local API for storing users, roles, and transactions in `data/store.js`.
Firebase Authentication is still used by the Flutter app, and the Flutter client sends the Firebase ID token to this API.

## Run

1. Install dependencies:

```bash
cd node_server
npm install
```

2. Add Firebase Admin credential:

- Download your Firebase service account JSON from Firebase Console.
- Save it as `node_server/serviceAccountKey.json`.

3. Configure env:

- Copy `.env.example` to `.env`
- Edit `ADMIN_EMAILS` to include the email address that should become admin automatically.

4. Start the API:

```bash
npm start
```

The API runs at `http://localhost:3000`.

## Flutter emulator URL

- Android emulator: `http://10.0.2.2:3000`
- Web: `http://localhost:3000`

## Stored data

- `data/store.js` stores:
  - `users`
  - `transactions`
  - `categories`

## Roles

- `admin`: can manage all users and all transactions.
- `user`: can only access their own transactions.

## Main endpoints

- `GET /health`
- `GET /me`
- `GET /categories`
- `GET /users` (admin only)
- `PATCH /users/:uid/role` (admin only)
- `GET /transactions`
- `POST /transactions`
- `PUT /transactions/:id`
- `DELETE /transactions/:id`

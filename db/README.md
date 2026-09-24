# CU Alerts API

Backend for the CU Alerts app: student authentication and report storage.
Node + Express + SQLite (via `better-sqlite3`, a file on disk, no separate
database server to run).

See **`../shared/api-contract.md`** for the full route/field reference —
that's the contract `ios/` and `web/` build against, keep it in sync with
any change here.

## Run it

```
cd db
npm install
npm start          # http://localhost:3000, writes to db/cualerts.sqlite
```

`npm run dev` restarts on file changes. Environment variables (all
optional, sane defaults for local dev):

| Variable | Default | Purpose |
|---|---|---|
| `PORT` | `3000` | HTTP port |
| `DB_PATH` | `db/cualerts.sqlite` | SQLite file location |
| `JWT_SECRET` | `dev-secret-change-me` | **Set a real one before deploying anywhere.** |
| `ALLOWED_EMAIL_DOMAIN` | `colorado.edu` | Registration is gated to `@<this>` |

## Test it

```
npm test
```

Runs `test/api.test.js` (Node's built-in test runner) against an
in-memory database — registration/login/validation and the reports
endpoints, including the "reports store no user link" invariant.

## Structure

```
db/
  server.js            entry point: opens the DB, starts listening
  src/
    app.js              Express app factory (routes, JSON body parsing, error handler)
    db.js               SQLite connection + schema migration
    config.js           env-driven config (JWT secret, allowed email domain)
    auth/routes.js       /api/auth/register, /login, /me + the requireAuth middleware
    reports/routes.js    /api/reports (GET, POST) — mounted behind requireAuth
  test/api.test.js       end-to-end tests against a real (in-memory) server
```

## Design notes

- **Reports are anonymous by storage, not by access.** Filing or reading a
  report requires a valid session (so we know it's a real CU student), but
  the `reports` table has no `user_id` column at all — the link is never
  created in the first place, not just hidden.
- **Auth is a plain JWT, no refresh tokens.** Tokens last 30 days
  (`JWT_EXPIRES_IN` in `config.js`). Good enough for a prototype; add
  refresh/rotation before this handles anything real.
- **Passwords are hashed with bcrypt** (`bcryptjs`, pure JS, no native
  build step) — never stored or logged in plaintext.

## Known gaps / next steps

- **Incident clustering is still client-side only** (see
  `ios/Sources/Services/IncidentClusterer.swift`). The server just stores
  and returns raw reports; it doesn't compute incidents. Moving that
  server-side means every client sees the same incidents (right now two
  people running the app could theoretically compute slightly different
  clusters if their clocks drift) and old reports can be pruned instead of
  growing the `GET /api/reports` payload forever.
- **No rate limiting / spam protection** beyond requiring a `@colorado.edu`
  login.
- **No account deletion, password reset, or email verification** — the
  domain check is the only proof of identity right now, there's no
  confirmation the person actually owns that inbox.
- **SQLite is a single file on one machine.** Fine for a capstone demo;
  revisit before this needs to run on more than one server instance.

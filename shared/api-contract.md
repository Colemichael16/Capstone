# CU Alerts API contract

Backend lives in `db/` (Node + Express + SQLite). This document is the
single source of truth both `web/` and `ios/` build their networking
layers against. If you change a route or a field here, update the backend
and both clients in the same change.

Base URL: `http://localhost:3000` in development (`PORT` env var to
change it). All request/response bodies are JSON.

## Auth

Registration is gated to `@colorado.edu` addresses (`ALLOWED_EMAIL_DOMAIN`
env var) — this is a CU Boulder campus app, and a real student email is
the whole anti-abuse story for now.

### `POST /api/auth/register`

Request:
```json
{ "email": "student@colorado.edu", "password": "at least 8 chars", "name": "Student Name" }
```

Response `201`:
```json
{ "token": "<jwt>", "user": { "id": "uuid", "email": "...", "name": "..." } }
```

Errors: `400` (invalid email/domain/password/name), `409` (email already registered).

### `POST /api/auth/login`

Request: `{ "email": "...", "password": "..." }`
Response `200`: same shape as register. Errors: `401` on bad credentials.

### `GET /api/auth/me`

Requires `Authorization: Bearer <token>`. Response `200`:
`{ "user": { "id", "email", "name" } }`. `401` if the token is missing/invalid, `404` if the user no longer exists.

## Reports

All `/api/reports` routes require `Authorization: Bearer <token>` — you
must be a signed-in student to read or write, but **reports themselves are
stored anonymously**: the server never records which user filed which
report (matches the client copy: "Reports are anonymous").

### `GET /api/reports`

Response `200`: `{ "reports": [Report, ...] }`, newest first.

### `POST /api/reports`

Request:
```json
{ "category": "Safety Concern", "latitude": 40.0077, "longitude": -105.2693, "note": "optional, <500 chars" }
```

`category` must be one of the values below. Response `201`: `{ "report": Report }`.
Errors: `400` on an invalid category/coordinate/note.

### `Report` shape

```json
{
  "id": "uuid",
  "category": "Safety Concern",
  "latitude": 40.0077,
  "longitude": -105.2693,
  "note": "",
  "createdAt": "2026-01-01T00:00:00.000Z"
}
```

Valid `category` values (must match `ReportCategory` in
`ios/Sources/Models/ReportCategory.swift` exactly):

- `Safety Concern`
- `Medical`
- `Fire / Smoke`
- `Suspicious Activity`
- `Hazard`
- `Crime in Progress`
- `Other`

## Incidents

There is no `/api/incidents` endpoint yet. Incident clustering
(`IncidentClusterer.swift`: same-category reports within 90m and 45
minutes, thresholds per category) currently runs **client-side only**,
against whatever `GET /api/reports` returns. Moving that to the server
(so every client sees the same computed incidents, and so old reports can
be pruned) is the next step — see "Known gaps" in `db/README.md`.

## Errors

Every error response is `{ "error": "human-readable message" }` with a
`4xx`/`5xx` status. Clients should show `error` directly; it's already
written for end users.

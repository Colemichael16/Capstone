# shared

Cross-project reference material — not code, since Swift (`ios/`) and
JS (`web/`, `db/`) can't literally share source. This is the single
written contract both sides build against.

- **`api-contract.md`** — every backend route, request/response shape,
  and the canonical list of report categories. If a route or field
  changes, update it here first, then the backend and both clients.

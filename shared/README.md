# shared

Cross-project reference material — not code, since Swift (`ios/`) and
JS (`web/`) can't literally share source. This is the single written
contract both sides build against.

- **`alert.schema.json`** — the `Alert` contract: status, category,
  severity, headline/message/instructions, the geofenced `center` +
  `radius_m`, issued/expires timestamps. Mirrors the `alerts` table in
  `db/migrations/20261014000000_alerts.sql` and the `alerts_feed` view
  both clients actually read from. If a field changes, update the schema,
  the migration, and both clients in the same change. Draft until the
  week-2 freeze (see the schema's own `description`); after that, change
  it only via a PR touching all three.

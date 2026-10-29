# db

Supabase schema for alerts. The web dispatcher writes alerts and the iOS app reads them over Realtime.

## Setup

1. Create a Supabase project.
2. In **SQL Editor**, run [migrations/20261014000000_alerts.sql](migrations/20261014000000_alerts.sql).
3. Create dispatcher accounts:
   - **Authentication > Users > Add user**, with an email and password, and auto-confirm turned on.
   - Grant the user publish rights:
     ```sql
     insert into public.dispatchers (user_id, display_name)
     select id, 'Jane Dispatcher' from auth.users where email = 'dispatcher@example.edu';
     ```
   A signed-in user who is not in `dispatchers` can't insert alerts, because RLS rejects it.
4. Copy the project URL and publishable key into `web/.env.local` (see `web/.env.example`).

## What's in the schema

| Object | Purpose |
| --- | --- |
| `alerts` | One row per alert. Matches `shared/alert.schema.json`. `center` is a PostGIS `geography(Point)`. The trigger also fills `center_geojson`, a GeoJSON copy. |
| `alerts_feed` (view) | The read path. Returns rows in contract shape, with `center` as GeoJSON. |
| `dispatchers` | Users allowed to publish. |

RLS:
- **Anyone, including anon:** can read alerts that are `active`/`updated` and not yet expired.
- **Dispatchers:** can read all alerts, insert alerts (`issued_by` must equal their own user id; it defaults to `auth.uid()`), and update alerts.

## Mobile (iOS) client

1. On launch, load the active alerts:
   ```swift
   let alerts: [Alert] = try await supabase
     .from("alerts_feed")
     .select()
     .in("status", values: ["active", "updated"])
     .gt("expires_at", value: Date())
     .execute().value
   ```
2. Subscribe to new and changed alerts:
   ```swift
   let channel = supabase.channel("alerts")
   let changes = channel.postgresChange(AnyAction.self, schema: "public", table: "alerts")
   await channel.subscribe()
   for await change in changes { /* refetch alerts_feed, or decode the record */ }
   ```
   Realtime payloads are raw `alerts` rows, so `center` comes through as EWKB hex. Read `center_geojson` for the point, or refetch `alerts_feed`.

Realtime applies RLS too: anon clients only get events for alerts that are currently active.

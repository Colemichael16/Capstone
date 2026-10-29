# CU Alerts (iOS)

SwiftUI client for the dispatcher alert system: campus staff publish
official alerts from the web app (`web/`), and this app shows them on a
live campus map plus gives walking directions across campus. iOS never
creates or edits an alert — that's the web dispatcher's job.

## What's here

```
ios/CUAlerts.xcodeproj/          the project — open this one
ios/Sources/
  App/
    CUAlertsApp.swift            entry point, wires up stores
    SupabaseConfig.swift         Supabase URL/key — blank by default (offline mode)
  Models/
    Alert.swift                  CampusAlert + its enums, matches shared/alert.schema.json
  Data/
    CampusLocations.swift        seed campus landmarks + emergency resources (for Directions)
    SampleAlerts.swift           offline demo alerts, mirrors web/src/alerts/sampleAlerts.js
  Services/
    AlertRepository.swift        OfflineAlertRepository + SupabaseAlertRepository (alerts_feed + Realtime)
    LocationManager.swift        CLLocationManager wrapper
    DirectionsService.swift      MKDirections walking-route wrapper
  Stores/
    AlertStore.swift             observable app state: active alerts, reloads on Realtime change
  Views/
    ContentView.swift            tab bar: Map / Directions
    CampusMapView.swift          the map: alert geofence circles + markers
    AlertDetailView.swift        alert detail sheet
    DirectionsView.swift         emergency route + campus destination picker
```

Open **`ios/CUAlerts.xcodeproj`** directly. In Finder, double-click it, or
from Terminal: `open ios/CUAlerts.xcodeproj`. Don't use Xcode's **File →
Open** dialog on a folder (`Capstone`, `ios`, or `Sources`) — Xcode treats a
plain folder as a loose file browser with no real target ("Files
.xcfilescontainer"), which isn't buildable. Only opening the `.xcodeproj`
item itself gives you a real project.

The project targets **iOS 17** and already has
`NSLocationWhenInUseUsageDescription` set via the generated Info.plist.

## Required one-time setup: add the Supabase package

This isn't done yet — adding a Swift Package dependency means Xcode has to
resolve it live against GitHub, which can't be done by hand-editing the
project file reliably. Before building:

1. In Xcode: **File → Add Package Dependencies…**
2. Paste `https://github.com/supabase/supabase-swift`
3. Add it to the **CUAlerts** target, with the **Supabase** product.

Once that's done, `import Supabase` in `AlertRepository.swift` resolves
and the project builds.

## Running without a backend (default)

`SupabaseConfig.url` and `.publishableKey` are blank by default, so
`AlertStore` falls back to `OfflineAlertRepository`, which serves
`CampusAlert.sampleAlerts` — the same three demo scenarios
(`sample-norlin`, `sample-chem`, `sample-weather`) as
`web/src/alerts/sampleAlerts.js`, so both clients show identical content
when run without Supabase configured. Build and run — no server needed.

## Connecting to the real backend

1. Set up Supabase per `db/README.md` (run the migration, create a
   dispatcher account).
2. Fill in `SupabaseConfig.url` / `.publishableKey` in
   `ios/Sources/App/SupabaseConfig.swift` (from the Supabase dashboard →
   Project Settings → API Keys — the publishable/anon key, never
   `service_role`). These are placeholders, not secrets to commit as-is —
   swap this for an untracked config (an `.xcconfig`, or a gitignored
   `Secrets.swift`) before this handles anything real.
3. Build and run. `AlertStore` now reads `alerts_feed` and subscribes to
   Realtime changes on the `alerts` table — publish an alert from the web
   dispatcher and it shows up here without a relaunch.

`AlertRepository.swift` mirrors `web/src/alerts/api.js` and the Swift
snippet already in `db/README.md` — that's the documented shape of this
client, not a guess.

## How alerts render on the map

- Each alert draws as a `MapCircle` sized in true meters at `radius_m`
  around its `center` — MapKit's circle overlay is natively geodesic, so
  (unlike `web/src/alerts/geo.js`, which has to hand-compute a polygon
  because a Mapbox GL `circle` layer is sized in pixels) no workaround is
  needed here.
- A marker at the center, icon by category, colored by severity (same hex
  values as `web/src/alerts/contract.js`'s `SEVERITY_COLORS`, so severity
  reads identically on both clients). Tap it for the full alert.

## How emergency directions work

- `DirectionsView` has an **Emergency Route** button that finds the
  nearest emergency resource (`CampusLocation.isEmergencyResource`, e.g.
  CU Police, Wardenburg) to the user's current location and routes to it.
- Below that is a normal picker for any seeded campus landmark.
- Routing uses `MKDirections` with `transportType = .walking`, returns a
  drawn polyline plus a step list.
- This is independent of the alert system — it doesn't currently route
  around active alert geofences. Worth adding once there's appetite for
  it, since `MKDirections` doesn't support custom avoidance zones on its
  own.

## Known gaps / next steps

- The web app's `MAP_STYLE` (a custom Mapbox style, see
  `web/src/config.js`) isn't used here — this map is plain MapKit, so the
  two clients don't currently render an identical basemap, only identical
  alert content/colors. Matching the basemap would mean swapping MapKit
  for the Mapbox Maps SDK for iOS, which is a separate decision (another
  SPM dependency, plus a Mapbox access token) — flag if that's wanted.
- No push notifications yet — the web app's `NotificationPreview.jsx`
  shows what a notification *would* look like, but nothing sends one.
- Campus coordinates in `CampusLocations.swift` (used only for the
  Directions tab) are approximate; swap in real building data when
  available.

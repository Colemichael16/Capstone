# RegentWatch (iOS)

SwiftUI client for the dispatcher alert system: campus staff publish
official alerts from the web app (`web/`), and this app shows them on a
live campus map plus gives walking directions across campus. iOS never
creates or edits an alert — that's the web dispatcher's job.

Branded **RegentWatch** (CFBundleDisplayName) per the project deck, though
the Xcode project/target is still named `CUAlerts` internally.

## What's here

```
ios/CUAlerts.xcodeproj/          the project — open this one
ios/Sources/
  App/
    CUAlertsApp.swift            entry point, wires up stores
    SupabaseConfig.swift         Supabase URL/key — blank by default (offline mode)
    Theme.swift                  CU brand colors (gold/black) + safe-zone/resource colors
  Models/
    Alert.swift                  CampusAlert + its enums, matches shared/alert.schema.json
    LocalInfoItem.swift          row model for the Local Information screen
  Data/
    CampusLocations.swift        seed campus landmarks, categorized safeZone/resource
    SampleAlerts.swift           offline demo alerts, mirrors web/src/alerts/sampleAlerts.js
    LocalInfoSamples.swift       static Events/Resources/Safety Tips content
  Services/
    AlertRepository.swift        OfflineAlertRepository + SupabaseAlertRepository (alerts_feed + Realtime)
    LocationManager.swift        CLLocationManager wrapper
    DirectionsService.swift      MKDirections walking-route wrapper
  Stores/
    AlertStore.swift             observable app state: active alerts, reloads on Realtime change
  Views/
    ContentView.swift            4-tab bar: Home / Alerts / Map / More
    HomeView.swift                headline alert banner + quick-access grid
    AlertsListView.swift          every active alert as a scannable list
    CampusMapView.swift          the map: alert geofences, safe-zone/resource pins, search + filter
    AlertDetailView.swift        alert detail sheet ("What is happening?" / "What should I do?")
    MoreView.swift                menu: Directions, Local Information
    LocalInfoView.swift          Events / Resources / Safety Tips, segmented
    SafetyTipsView.swift         static safety tips sheet
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

If you still see "No such module 'Supabase'" after that, it's almost
always that the package got added to the *project* but not linked to the
*target*: select the **CUAlerts** target → **General** → **Frameworks,
Libraries, and Embedded Content** → **+** → add **Supabase** there too,
then **Product → Clean Build Folder** (⇧⌘K) and rebuild.

## Design direction

The UI follows the mockups in the team's project update deck: a
**RegentWatch**-branded home screen with a prominent alert banner and a
2×2 quick-access grid, a dedicated Alerts list, a Campus Map with a
search bar and All/Alerts/Safe Zones/Resources filter pills, and a
Local Information screen (Events/Resources/Safety Tips). CU brand colors
(gold `#CFB87C`, black) are in `Theme.swift`. One deliberate deviation:
the deck's "Report" quick-access button was repurposed as **Directions**
— there's no citizen-reporting feature in this app (alerts are
dispatcher-issued only), so the original "Report" slot would have gone to
nothing.

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
- Safe zones (CU Police, Wardenburg) and everyday resources (library,
  UMC, etc.) from `CampusLocations.swift` show as green/blue pins, and the
  filter pills toggle each layer — matches the map pin legend in the deck.

## How emergency directions work

- `DirectionsView` (under the **More** tab) has an **Emergency Route**
  button that finds the nearest safe zone (`CampusLocation.category ==
  .safeZone`, e.g. CU Police, Wardenburg) to the user's current location
  and routes to it.
- Below that is a normal picker for any seeded campus landmark.
- Routing uses `MKDirections` with `transportType = .walking`, returns a
  drawn polyline plus a step list.
- This is independent of the alert system — it doesn't currently route
  around active alert geofences. Worth adding once there's appetite for
  it, since `MKDirections` doesn't support custom avoidance zones on its
  own.

## Known gaps / next steps

- **Local Information is static sample content** (`LocalInfoSamples.swift`)
  — campus closures, events, weather, transit. There's no real data
  source behind any of it yet.
- The web app's `MAP_STYLE` (a custom Mapbox style, see
  `web/src/config.js`) isn't used here — this map is plain MapKit, so the
  two clients don't currently render an identical basemap, only identical
  alert content/colors. Matching the basemap would mean swapping MapKit
  for the Mapbox Maps SDK for iOS, which is a separate decision (another
  SPM dependency, plus a Mapbox access token) — flag if that's wanted.
- No actual CU logo asset — the home screen header is text-only
  ("Regent" in black, "Watch" in gold). Needs a real app icon and logo
  image before this ships.
- No push notifications yet — the web app's `NotificationPreview.jsx`
  shows what a notification *would* look like, but nothing sends one.
- Campus coordinates in `CampusLocations.swift` are approximate; swap in
  real building data when available.

# CU Alerts (iOS)

SwiftUI prototype: a campus map where enough reports near the same spot
turn into a visible incident, plus emergency walking directions to the
nearest help.

## What's here

```
ios/CUAlerts.xcodeproj/          the project — open this one
ios/Sources/
  App/
    CUAlertsApp.swift            entry point, wires up stores + repository choice
    AppConfig.swift              useRemoteBackend toggle, API base URL
  Models/                        Report, Incident, ReportCategory, User
  Data/
    CampusLocations.swift        seed campus landmarks + emergency resources
    SampleData.swift             seed reports so the map isn't empty on first launch
  Services/
    IncidentClusterer.swift      groups nearby/recent reports into an Incident
    ReportRepository.swift       storage boundary: InMemoryReportRepository (default)
    RemoteReportRepository.swift storage boundary: talks to db/ instead
    APIClient.swift               generic JSON client for db/ (see shared/api-contract.md)
    AuthService.swift             /api/auth/* calls
    JSONCoding+API.swift          date decoding that matches the backend's timestamp format
    KeychainStore.swift           persists the auth session across launches
    LocationManager.swift        CLLocationManager wrapper
    DirectionsService.swift      MKDirections walking-route wrapper
  Stores/
    ReportStore.swift            observable app state: reports + derived incidents
    AuthStore.swift               observable session state: current user, login/register/logout
  Views/
    RootView.swift                shows LoginView or ContentView depending on auth state
    ContentView.swift            tab bar: Map / Directions (+ Account, if useRemoteBackend)
    CampusMapView.swift          the map, long-press to file a report
    ReportSheetView.swift        report form
    IncidentDetailView.swift     incident detail sheet
    DirectionsView.swift         emergency route + campus destination picker
    LoginView.swift / SignUpView.swift / AccountView.swift
```

Open **`ios/CUAlerts.xcodeproj`** directly. In Finder, double-click it, or
from Terminal: `open ios/CUAlerts.xcodeproj`. Don't use Xcode's **File →
Open** dialog on a folder (`Capstone`, `ios`, or `Sources`) — Xcode treats a
plain folder as a loose file browser with no real target ("Files
.xcfilescontainer"), which isn't buildable. Only opening the `.xcodeproj`
item itself gives you a real project.

The project targets **iOS 17** (the map code uses the iOS 17
`Map(position:)` / `MapReader` APIs) and already has
`NSLocationWhenInUseUsageDescription` set via the generated Info.plist —
nothing else to configure. Pick a simulator or device and hit Run.

## How the report → incident pipeline works

- Anyone can file a `Report` (category + optional note) at a coordinate by
  long-pressing the map.
- `IncidentClusterer` groups reports of the same category that are within
  **90m** and **45 minutes** of each other.
- Once a cluster's size crosses that category's threshold
  (`ReportCategory.incidentThreshold` — 2 for fire/crime/medical, 3 for
  safety/suspicious/hazard, 4 for other), it becomes a visible `Incident`
  marker on the map, colored/sized by severity.
- Reports that haven't crossed the threshold still show as small dots, so
  early signal isn't hidden, but it's visually distinct from a confirmed
  incident.

## How emergency directions work

- `DirectionsView` has an **Emergency Route** button that finds the nearest
  emergency resource (`CampusLocation.isEmergencyResource`, e.g. CU Police,
  Wardenburg) to the user's current location and routes to it.
- Below that is a normal picker for any seeded campus landmark.
- Routing uses `MKDirections` with `transportType = .walking`, returns a
  drawn polyline plus a step list.

## Connecting to the real backend

By default the app runs **standalone**: `AppConfig.useRemoteBackend` is
`false`, so it uses `InMemoryReportRepository` seeded with
`Report.sampleData` and skips login entirely — this is what you get out of
the box, no server required.

To use the real `db/` backend instead:

1. Run the backend (`cd db && npm install && npm start` — see
   `db/README.md`).
2. Flip `AppConfig.useRemoteBackend` to `true` in
   `ios/Sources/App/AppConfig.swift`.
3. Build and run. You'll land on `LoginView` first — registration requires
   a `@colorado.edu` email (see `shared/api-contract.md`); once signed in,
   reports are fetched from and filed against the real server, and a third
   **Account** tab appears with a sign-out button.

The Simulator can reach `http://localhost:3000` directly. On a physical
device, point `AppConfig.apiBaseURL` at your Mac's LAN IP instead of
`localhost`.

Everything in `Services/` and `Stores/AuthStore.swift` talks to the
contract in **`../shared/api-contract.md`** — that's the source of truth
for every route and field shape.

## Known gaps / next steps

- Reports are unmoderated once filed — auth only proves the submitter is a
  real CU student, it doesn't prevent spam or false reports.
- Incident clustering still runs client-side only, against whatever
  `GET /api/reports` returns (see "Known gaps" in `db/README.md` — moving
  it server-side is the next step there).
- No password reset, account deletion, or email verification flow yet.
- Routing doesn't currently avoid areas with active incidents — worth
  adding once there's a real routing backend, since `MKDirections` doesn't
  support custom avoidance zones on its own.
- Campus coordinates in `CampusLocations.swift` are approximate; swap in
  real building data when available.

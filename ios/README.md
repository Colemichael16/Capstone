# CU Alerts (iOS)

SwiftUI prototype: a campus map where enough reports near the same spot
turn into a visible incident, plus emergency walking directions to the
nearest help.

## What's here

```
ios/CUAlerts/
  App/CUAlertsApp.swift          entry point, wires up stores
  Models/                        Report, Incident, ReportCategory
  Data/CampusLocations.swift     seed campus landmarks + emergency resources
  Services/
    IncidentClusterer.swift      groups nearby/recent reports into an Incident
    ReportRepository.swift       storage boundary (in-memory now, swap for a real backend later)
    LocationManager.swift        CLLocationManager wrapper
    DirectionsService.swift      MKDirections walking-route wrapper
  Stores/ReportStore.swift       observable app state: reports + derived incidents
  Views/
    ContentView.swift            tab bar: Map / Directions
    CampusMapView.swift          the map, long-press to file a report
    ReportSheetView.swift        report form
    IncidentDetailView.swift     incident detail sheet
    DirectionsView.swift         emergency route + campus destination picker
```

This is source-only — there's no `.xcodeproj` yet. Create one and drop these
files in:

1. In Xcode: **File → New → Project → iOS → App**, name it `CUAlerts`,
   interface **SwiftUI**, minimum deployment target **iOS 17** (the map code
   uses the iOS 17 `Map(position:)` / `MapReader` APIs).
2. Delete the template's `ContentView.swift` / `App.swift`, then drag the
   `App/`, `Models/`, `Data/`, `Services/`, `Stores/`, and `Views/` folders
   from `ios/CUAlerts/` into the project (check "Copy items if needed" and
   add to the app target).
3. Add these keys to `Info.plist` (required — the app crashes on location
   requests without them):
   - `NSLocationWhenInUseUsageDescription` — e.g. "Used to show your
     position on the campus map and calculate walking directions."
4. Build & run on a simulator or device.

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

## Known gaps / next steps

- All data is in-memory and resets on relaunch. `ReportRepository` is a
  protocol specifically so a networked implementation can be swapped in
  once there's a backend in `db/` — nothing else in the app needs to change.
- Reports are unauthenticated and unmoderated; there's no abuse/spam
  protection yet.
- Routing doesn't currently avoid areas with active incidents — worth
  adding once there's a real routing backend, since `MKDirections` doesn't
  support custom avoidance zones on its own.
- Campus coordinates in `CampusLocations.swift` are approximate; swap in
  real building data when available.

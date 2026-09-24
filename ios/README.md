# CU Alerts (iOS)

SwiftUI prototype: a campus map where enough reports near the same spot
turn into a visible incident, plus emergency walking directions to the
nearest help.

## What's here

```
ios/CUAlerts.xcodeproj/          open this — do NOT File → Open the CUAlerts/ folder directly
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

Open **`ios/CUAlerts.xcodeproj`** directly (double-click it, or `open
ios/CUAlerts.xcodeproj` from Terminal) and build. Don't use **File → Open**
on the `CUAlerts/` source folder itself — Xcode will treat it as a loose
folder with no real target ("Files.xcfilescontainer"), which isn't
buildable.

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

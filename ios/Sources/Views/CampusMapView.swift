import CoreLocation
import MapKit
import SwiftUI

private enum MapFilter: String, CaseIterable, Hashable {
    case all = "All"
    case alerts = "Alerts"
    case safeZones = "Safe Zones"
    case resources = "Resources"
}

/// Campus map: active dispatcher alerts (geofence circle + marker), plus
/// safe-zone/resource pins and a search/filter bar, matching the "Campus
/// Map" screen in the project deck. Each alert circle is drawn true to
/// scale in meters (`MapCircle` is natively geodesic) — unlike a Mapbox GL
/// `circle` layer, which web/src/alerts/geo.js has to hand-compute a
/// polygon to get right.
struct CampusMapView: View {
    @EnvironmentObject private var alertStore: AlertStore

    @State private var cameraPosition: MapCameraPosition = .region(Campus.defaultRegion)
    @State private var selectedAlert: CampusAlert?
    @State private var searchText = ""
    @State private var filter: MapFilter = .all

    private var filteredLocations: [CampusLocation] {
        let matchingSearch = searchText.isEmpty
            ? Campus.locations
            : Campus.locations.filter { $0.name.localizedCaseInsensitiveContains(searchText) }

        switch filter {
        case .all: return matchingSearch
        case .alerts: return []
        case .safeZones: return matchingSearch.filter { $0.category == .safeZone }
        case .resources: return matchingSearch.filter { $0.category == .resource }
        }
    }

    private var showAlerts: Bool {
        filter == .all || filter == .alerts
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                searchAndFilterBar

                Map(position: $cameraPosition) {
                    UserAnnotation()

                    if showAlerts {
                        ForEach(alertStore.alerts) { alert in
                            MapCircle(center: alert.center, radius: Double(alert.radiusM))
                                .foregroundStyle(alert.severity.color.opacity(0.18))
                                .stroke(alert.severity.color, lineWidth: 2)

                            Annotation(alert.headline, coordinate: alert.center) {
                                AlertMarker(alert: alert)
                                    .onTapGesture { selectedAlert = alert }
                            }
                        }
                    }

                    ForEach(filteredLocations) { location in
                        Annotation(location.name, coordinate: location.coordinate) {
                            LocationMarker(location: location)
                        }
                    }
                }
                .overlay {
                    if alertStore.alerts.isEmpty && !alertStore.isLoading && filter != .safeZones && filter != .resources {
                        ContentUnavailableView(
                            "No Active Alerts",
                            systemImage: "checkmark.shield",
                            description: Text("You'll see official campus alerts here as they're issued.")
                        )
                        .background(.thinMaterial)
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(item: $selectedAlert) { alert in
                AlertDetailView(alert: alert)
            }
        }
        .task {
            await alertStore.start()
        }
    }

    private var searchAndFilterBar: some View {
        VStack(spacing: 10) {
            HStack {
                Text("Campus Map")
                    .font(.title2.bold())
                Spacer()
            }

            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Search buildings, events, or alerts…", text: $searchText)
            }
            .padding(10)
            .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 10))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(MapFilter.allCases, id: \.self) { option in
                        FilterPill(title: option.rawValue, isSelected: filter == option, tint: tint(for: option)) {
                            filter = option
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
        .padding(.bottom, 10)
    }

    private func tint(for filter: MapFilter) -> Color {
        switch filter {
        case .all: return Theme.cuBlack
        case .alerts: return .red
        case .safeZones: return Theme.safeZone
        case .resources: return Theme.resource
        }
    }
}

private struct FilterPill: View {
    let title: String
    let isSelected: Bool
    let tint: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.bold())
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(isSelected ? tint : Color(.secondarySystemBackground), in: Capsule())
                .foregroundStyle(isSelected ? .white : .primary)
        }
        .buttonStyle(.plain)
    }
}

private struct AlertMarker: View {
    let alert: CampusAlert

    var body: some View {
        Image(systemName: alert.category.systemImage)
            .font(.headline)
            .foregroundStyle(.white)
            .padding(8)
            .background(alert.severity.color, in: Circle())
            .overlay(Circle().stroke(.white, lineWidth: 2))
    }
}

private struct LocationMarker: View {
    let location: CampusLocation

    var body: some View {
        Image(systemName: location.category.systemImage)
            .font(.caption)
            .foregroundStyle(.white)
            .padding(6)
            .background(location.category.color, in: Circle())
            .overlay(Circle().stroke(.white, lineWidth: 1.5))
    }
}

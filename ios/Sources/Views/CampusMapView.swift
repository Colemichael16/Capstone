import CoreLocation
import MapKit
import SwiftUI

/// The main screen: active dispatcher alerts on the campus map, each drawn
/// as a true-to-scale geofence circle (`MapCircle` is sized in real
/// meters, unlike a Mapbox GL `circle` layer, so no custom-polygon
/// workaround is needed here the way web/src/alerts/geo.js has one) plus a
/// marker at its center. Tap a marker for the full alert.
struct CampusMapView: View {
    @EnvironmentObject private var alertStore: AlertStore

    @State private var cameraPosition: MapCameraPosition = .region(Campus.defaultRegion)
    @State private var selectedAlert: CampusAlert?

    var body: some View {
        NavigationStack {
            Map(position: $cameraPosition) {
                UserAnnotation()

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
            .mapControls {
                MapUserLocationButton()
                MapCompass()
            }
            .sheet(item: $selectedAlert) { alert in
                AlertDetailView(alert: alert)
            }
            .overlay {
                if alertStore.alerts.isEmpty && !alertStore.isLoading {
                    ContentUnavailableView(
                        "No Active Alerts",
                        systemImage: "checkmark.shield",
                        description: Text("You'll see official campus alerts here as they're issued.")
                    )
                }
            }
        }
        .task {
            await alertStore.start()
        }
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

import CoreLocation
import MapKit
import SwiftUI

/// The main "Apple Maps for CU Boulder" screen: shows active incidents,
/// lower-confidence standalone reports, and the user's own location.
/// Long-press anywhere on the map to file a report at that spot.
struct CampusMapView: View {
    @EnvironmentObject private var reportStore: ReportStore
    @EnvironmentObject private var locationManager: LocationManager

    @State private var cameraPosition: MapCameraPosition = .region(Campus.defaultRegion)
    @State private var pendingReportCoordinate: CLLocationCoordinate2D?
    @State private var selectedIncident: Incident?

    var body: some View {
        NavigationStack {
            MapReader { proxy in
                Map(position: $cameraPosition) {
                    UserAnnotation()

                    ForEach(reportStore.incidents) { incident in
                        Annotation(incident.category.rawValue, coordinate: incident.coordinate) {
                            IncidentMarker(incident: incident)
                                .onTapGesture { selectedIncident = incident }
                        }
                    }

                    ForEach(reportStore.unclusteredReports) { report in
                        Annotation(report.category.rawValue, coordinate: report.coordinate.value) {
                            Circle()
                                .fill(report.category.color.opacity(0.6))
                                .frame(width: 10, height: 10)
                        }
                    }
                }
                .mapControls {
                    MapUserLocationButton()
                    MapCompass()
                }
                .gesture(
                    LongPressGesture(minimumDuration: 0.4)
                        .sequenced(before: DragGesture(minimumDistance: 0))
                        .onEnded { value in
                            guard case .second(true, let drag?) = value else { return }
                            if let coordinate = proxy.convert(drag.location, from: .local) {
                                pendingReportCoordinate = coordinate
                            }
                        }
                )
            }
            .sheet(item: $selectedIncident) { incident in
                IncidentDetailView(incident: incident)
            }
            .sheet(isPresented: Binding(
                get: { pendingReportCoordinate != nil },
                set: { if !$0 { pendingReportCoordinate = nil } }
            )) {
                if let coordinate = pendingReportCoordinate {
                    ReportSheetView(coordinate: coordinate) {
                        pendingReportCoordinate = nil
                    }
                }
            }
            .overlay(alignment: .bottom) {
                Text("Press and hold a spot on the map to file a report")
                    .font(.footnote)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.thinMaterial, in: Capsule())
                    .padding(.bottom, 12)
            }
        }
    }
}

private struct IncidentMarker: View {
    let incident: Incident

    var body: some View {
        VStack(spacing: 2) {
            Image(systemName: incident.category.systemImage)
                .font(.headline)
                .foregroundStyle(.white)
                .padding(8)
                .background(color, in: Circle())
                .overlay(Circle().stroke(.white, lineWidth: 2))
            Text("\(incident.reportCount)")
                .font(.caption2.bold())
                .padding(.horizontal, 6)
                .padding(.vertical, 1)
                .background(color, in: Capsule())
                .foregroundStyle(.white)
        }
    }

    private var color: Color {
        switch incident.severity {
        case .low: return .yellow
        case .moderate: return .orange
        case .high: return .red
        case .critical: return .purple
        }
    }
}

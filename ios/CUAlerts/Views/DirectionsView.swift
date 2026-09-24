import CoreLocation
import MapKit
import SwiftUI

/// Turn-by-turn walking directions across campus. "Emergency Route"
/// shortcuts straight to the nearest emergency resource (CU Police,
/// Wardenburg) from wherever the user is standing; the picker below lets
/// them route to any campus landmark normally.
struct DirectionsView: View {
    @EnvironmentObject private var locationManager: LocationManager

    @State private var destination: CampusLocation?
    @State private var route: WalkingRoute?
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var cameraPosition: MapCameraPosition = .region(Campus.defaultRegion)

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Map(position: $cameraPosition) {
                    UserAnnotation()

                    if let destination {
                        Marker(destination.name, coordinate: destination.coordinate)
                    }

                    if let route {
                        MapPolyline(route.polyline)
                            .stroke(.blue, lineWidth: 5)
                    }
                }
                .frame(height: 280)

                List {
                    Section {
                        Button {
                            routeToNearestEmergencyResource()
                        } label: {
                            Label("Emergency Route: nearest help", systemImage: "sos")
                                .foregroundStyle(.red)
                                .fontWeight(.semibold)
                        }
                    }

                    Section("Or pick a destination") {
                        ForEach(Campus.locations) { location in
                            Button {
                                destination = location
                                Task { await calculateRoute(to: location) }
                            } label: {
                                VStack(alignment: .leading) {
                                    Text(location.name).foregroundStyle(.primary)
                                    Text(location.subtitle)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }

                    if let route {
                        Section("Route") {
                            LabeledContent("Distance", value: distanceLabel(route.distanceMeters))
                            LabeledContent("Walking time", value: durationLabel(route.expectedTravelTime))
                        }

                        Section("Steps") {
                            ForEach(Array(route.steps.enumerated()), id: \.offset) { _, step in
                                if !step.instructions.isEmpty {
                                    Text(step.instructions)
                                }
                            }
                        }
                    }

                    if isLoading {
                        ProgressView("Finding route…")
                    }

                    if let errorMessage {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                            .font(.footnote)
                    }
                }
            }
            .navigationTitle("Directions")
        }
    }

    private func routeToNearestEmergencyResource() {
        guard let origin = locationManager.coordinate else {
            errorMessage = "Turn on location access to use emergency routing."
            return
        }
        guard let nearest = Campus.nearestEmergencyResource(to: origin) else { return }
        destination = nearest
        Task { await calculateRoute(to: nearest) }
    }

    private func calculateRoute(to destination: CampusLocation) async {
        guard let origin = locationManager.coordinate else {
            errorMessage = "Turn on location access to get directions."
            return
        }
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        do {
            let result = try await DirectionsService.walkingRoute(from: origin, to: destination.coordinate)
            route = result
            cameraPosition = .rect(result.polyline.boundingMapRect)
        } catch {
            errorMessage = "Couldn't find a walking route. Try again."
        }
    }

    private func distanceLabel(_ meters: CLLocationDistance) -> String {
        Measurement(value: meters, unit: UnitLength.meters)
            .formatted(.measurement(width: .abbreviated, usage: .road))
    }

    private func durationLabel(_ seconds: TimeInterval) -> String {
        let minutes = max(1, Int(seconds / 60))
        return "\(minutes) min"
    }
}

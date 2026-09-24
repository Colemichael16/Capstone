import CoreLocation
import MapKit

struct WalkingRoute {
    let polyline: MKPolyline
    let steps: [MKRoute.Step]
    let expectedTravelTime: TimeInterval
    let distanceMeters: CLLocationDistance
}

enum DirectionsError: Error {
    case noRouteFound
}

/// Wraps `MKDirections` for walking routes between two campus points. Used
/// both for normal "get me there" directions and for the emergency flow,
/// where the destination defaults to the nearest emergency resource.
enum DirectionsService {
    static func walkingRoute(
        from origin: CLLocationCoordinate2D,
        to destination: CLLocationCoordinate2D
    ) async throws -> WalkingRoute {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: origin))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
        request.transportType = .walking
        request.requestsAlternateRoutes = false

        let directions = MKDirections(request: request)
        let response = try await directions.calculate()

        guard let route = response.routes.first else {
            throw DirectionsError.noRouteFound
        }

        return WalkingRoute(
            polyline: route.polyline,
            steps: route.steps,
            expectedTravelTime: route.expectedTravelTime,
            distanceMeters: route.distance
        )
    }
}

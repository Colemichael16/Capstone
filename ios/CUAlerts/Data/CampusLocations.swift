import CoreLocation
import MapKit

/// A named, searchable destination on campus (building, emergency resource,
/// etc.) used to seed the directions picker and the map's default region.
struct CampusLocation: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let subtitle: String
    let coordinate: CLLocationCoordinate2D
    let isEmergencyResource: Bool

    static func == (lhs: CampusLocation, rhs: CampusLocation) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

enum Campus {
    /// Approximate center of the CU Boulder campus.
    static let center = CLLocationCoordinate2D(latitude: 40.0076, longitude: -105.2659)

    static let defaultRegion = MKCoordinateRegion(
        center: center,
        span: MKCoordinateSpan(latitudeDelta: 0.018, longitudeDelta: 0.018)
    )

    /// Seed data. Coordinates are approximate campus landmarks, good enough
    /// for a prototype; swap for a real building dataset once `db/` exists.
    static let locations: [CampusLocation] = [
        CampusLocation(
            name: "CU Police Department",
            subtitle: "Emergency response, 24/7",
            coordinate: CLLocationCoordinate2D(latitude: 40.00847, longitude: -105.26661),
            isEmergencyResource: true
        ),
        CampusLocation(
            name: "Wardenburg Health Center",
            subtitle: "Urgent & primary care",
            coordinate: CLLocationCoordinate2D(latitude: 40.00590, longitude: -105.26991),
            isEmergencyResource: true
        ),
        CampusLocation(
            name: "University Memorial Center (UMC)",
            subtitle: "Student union",
            coordinate: CLLocationCoordinate2D(latitude: 40.00775, longitude: -105.26935),
            isEmergencyResource: false
        ),
        CampusLocation(
            name: "Norlin Library",
            subtitle: "Main library",
            coordinate: CLLocationCoordinate2D(latitude: 40.00680, longitude: -105.27060),
            isEmergencyResource: false
        ),
        CampusLocation(
            name: "Folsom Field",
            subtitle: "Stadium",
            coordinate: CLLocationCoordinate2D(latitude: 40.00849, longitude: -105.26643),
            isEmergencyResource: false
        ),
        CampusLocation(
            name: "Engineering Center",
            subtitle: "College of Engineering",
            coordinate: CLLocationCoordinate2D(latitude: 40.00580, longitude: -105.26210),
            isEmergencyResource: false
        ),
        CampusLocation(
            name: "Williams Village",
            subtitle: "Residence halls",
            coordinate: CLLocationCoordinate2D(latitude: 40.00230, longitude: -105.25710),
            isEmergencyResource: false
        ),
        CampusLocation(
            name: "Coors Events Center",
            subtitle: "Arena",
            coordinate: CLLocationCoordinate2D(latitude: 40.00460, longitude: -105.26370),
            isEmergencyResource: false
        ),
    ]

    static func nearestEmergencyResource(to coordinate: CLLocationCoordinate2D) -> CampusLocation? {
        let origin = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        return locations
            .filter(\.isEmergencyResource)
            .min { a, b in
                let da = CLLocation(latitude: a.coordinate.latitude, longitude: a.coordinate.longitude).distance(from: origin)
                let db = CLLocation(latitude: b.coordinate.latitude, longitude: b.coordinate.longitude).distance(from: origin)
                return da < db
            }
    }
}

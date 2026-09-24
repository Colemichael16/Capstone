import CoreLocation
import Foundation

/// A single report filed by a user at a point on campus. Reports are the
/// raw signal; enough of them clustered together become an `Incident`.
struct Report: Identifiable, Codable, Equatable {
    let id: UUID
    let category: ReportCategory
    let coordinate: CodableCoordinate
    let note: String
    let createdAt: Date

    init(
        id: UUID = UUID(),
        category: ReportCategory,
        coordinate: CLLocationCoordinate2D,
        note: String,
        createdAt: Date = .now
    ) {
        self.id = id
        self.category = category
        self.coordinate = CodableCoordinate(coordinate)
        self.note = note
        self.createdAt = createdAt
    }
}

/// `CLLocationCoordinate2D` doesn't conform to `Codable` on its own, so we
/// wrap it. Keeps `Report`/`Incident` trivially serializable once a backend
/// lands in `shared/`.
struct CodableCoordinate: Codable, Equatable {
    var latitude: CLLocationDegrees
    var longitude: CLLocationDegrees

    init(_ coordinate: CLLocationCoordinate2D) {
        latitude = coordinate.latitude
        longitude = coordinate.longitude
    }

    var value: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

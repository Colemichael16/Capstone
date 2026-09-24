import CoreLocation
import Foundation

extension Report {
    /// Seed data so the map and directions screens show something on first
    /// launch instead of a blank map. Timestamps are relative to "now" so
    /// they always land inside `IncidentClusterer`'s time window regardless
    /// of when the app is actually run.
    static var sampleData: [Report] {
        let now = Date()

        return [
            // Safety concern cluster near the UMC — 3 reports, crosses that
            // category's threshold of 3, so this becomes a visible incident.
            Report(
                category: .safety,
                coordinate: CLLocationCoordinate2D(latitude: 40.00778, longitude: -105.26930),
                note: "Someone yelling near the fountain",
                createdAt: now.addingTimeInterval(-18 * 60)
            ),
            Report(
                category: .safety,
                coordinate: CLLocationCoordinate2D(latitude: 40.00772, longitude: -105.26941),
                note: "Same thing, still going on",
                createdAt: now.addingTimeInterval(-11 * 60)
            ),
            Report(
                category: .safety,
                coordinate: CLLocationCoordinate2D(latitude: 40.00781, longitude: -105.26928),
                note: "",
                createdAt: now.addingTimeInterval(-4 * 60)
            ),

            // Medical cluster near Norlin Library — 2 reports, crosses that
            // category's threshold of 2.
            Report(
                category: .medical,
                coordinate: CLLocationCoordinate2D(latitude: 40.00683, longitude: -105.27055),
                note: "Person on the ground by the entrance",
                createdAt: now.addingTimeInterval(-9 * 60)
            ),
            Report(
                category: .medical,
                coordinate: CLLocationCoordinate2D(latitude: 40.00677, longitude: -105.27063),
                note: "Confirmed, still there",
                createdAt: now.addingTimeInterval(-3 * 60)
            ),

            // Standalone reports, below their category's threshold, so they
            // show as low-key dots rather than incident markers.
            Report(
                category: .hazard,
                coordinate: CLLocationCoordinate2D(latitude: 40.00583, longitude: -105.26205),
                note: "Downed branch blocking the path",
                createdAt: now.addingTimeInterval(-25 * 60)
            ),
            Report(
                category: .suspiciousActivity,
                coordinate: CLLocationCoordinate2D(latitude: 40.00227, longitude: -105.25716),
                note: "",
                createdAt: now.addingTimeInterval(-30 * 60)
            ),
        ]
    }
}

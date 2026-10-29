import CoreLocation
import Foundation

extension CampusAlert {
    /// Offline stand-in, used when `SupabaseConfig` has no URL/key set —
    /// exactly mirrors web/src/alerts/sampleAlerts.js (same ids, content,
    /// coordinates, radii) so both clients show the same three demo
    /// scenarios when run without a backend.
    static var sampleAlerts: [CampusAlert] {
        let now = Date()
        func hoursFromNow(_ hours: Double) -> Date {
            now.addingTimeInterval(hours * 3600)
        }

        return [
            CampusAlert(
                id: "sample-norlin",
                status: .active,
                category: .activeThreat,
                severity: .extreme,
                headline: "Police response near Norlin Library",
                shortMessage: "Avoid Norlin Quad. Shelter in place if nearby.",
                fullDetails: "CUPD is responding to a reported threat near Norlin Library.",
                instructions: "Avoid Norlin Quad. Shelter in place and lock doors.",
                center: CLLocationCoordinate2D(latitude: 40.0088, longitude: -105.2706),
                radiusM: 150,
                issuedBy: nil,
                issuedAt: hoursFromNow(-0.25),
                expiresAt: hoursFromNow(2)
            ),
            CampusAlert(
                id: "sample-chem",
                status: .active,
                category: .hazmat,
                severity: .severe,
                headline: "Chemical spill in chemistry building",
                shortMessage: "Chemical spill reported. Stay out of the building until cleared.",
                fullDetails: "Boulder Fire hazmat team on scene.",
                instructions: "Evacuate the building and stay upwind.",
                center: CLLocationCoordinate2D(latitude: 40.0069, longitude: -105.2722),
                radiusM: 100,
                issuedBy: nil,
                issuedAt: hoursFromNow(-0.5),
                expiresAt: hoursFromNow(3)
            ),
            CampusAlert(
                id: "sample-weather",
                status: .active,
                category: .weather,
                severity: .moderate,
                headline: "Severe thunderstorm warning",
                shortMessage: "Lightning and hail expected. Move indoors.",
                fullDetails: nil,
                instructions: "Stay indoors until the warning expires.",
                center: CLLocationCoordinate2D(latitude: 40.0074, longitude: -105.27),
                radiusM: 900,
                issuedBy: nil,
                issuedAt: hoursFromNow(-1),
                expiresAt: hoursFromNow(1)
            ),
        ]
    }
}

import CoreLocation
import Foundation

/// Turns a flat stream of `Report`s into `Incident`s: independent reports of
/// the same category, close together in both space and time, get merged
/// into a single alert. This is what "enough reports leading to an
/// incident" means in practice.
enum IncidentClusterer {
    /// Reports further apart than this are treated as unrelated.
    static let clusterRadiusMeters: CLLocationDistance = 90
    /// Reports older than this relative to the newest one in a cluster are
    /// dropped — an incident should reflect what's happening *now*.
    static let clusterWindow: TimeInterval = 45 * 60

    /// Recomputes the full incident list from scratch given every report on
    /// file. Simple and correct for a prototype's report volume; revisit if
    /// this ever needs to scale past a few thousand live reports.
    static func buildIncidents(from reports: [Report]) -> [Incident] {
        var incidents: [Incident] = []
        let byCategory = Dictionary(grouping: reports, by: \.category)

        for (category, categoryReports) in byCategory {
            var remaining = categoryReports.sorted { $0.createdAt < $1.createdAt }

            while let seed = remaining.first {
                var cluster = [seed]
                remaining.removeFirst()

                var didGrow = true
                while didGrow {
                    didGrow = false
                    remaining.removeAll { candidate in
                        guard cluster.contains(where: { isRelated($0, candidate) }) else { return false }
                        cluster.append(candidate)
                        didGrow = true
                        return true
                    }
                }

                guard cluster.count >= category.incidentThreshold else { continue }

                incidents.append(
                    Incident(
                        id: UUID(),
                        category: category,
                        coordinate: centroid(of: cluster),
                        reportIDs: cluster.map(\.id),
                        firstReportedAt: cluster.map(\.createdAt).min() ?? seed.createdAt,
                        lastReportedAt: cluster.map(\.createdAt).max() ?? seed.createdAt
                    )
                )
            }
        }

        return incidents.sorted { $0.lastReportedAt > $1.lastReportedAt }
    }

    private static func isRelated(_ a: Report, _ b: Report) -> Bool {
        guard abs(a.createdAt.timeIntervalSince(b.createdAt)) <= clusterWindow else { return false }
        let locA = CLLocation(latitude: a.coordinate.value.latitude, longitude: a.coordinate.value.longitude)
        let locB = CLLocation(latitude: b.coordinate.value.latitude, longitude: b.coordinate.value.longitude)
        return locA.distance(from: locB) <= clusterRadiusMeters
    }

    private static func centroid(of reports: [Report]) -> CLLocationCoordinate2D {
        let lat = reports.map { $0.coordinate.value.latitude }.reduce(0, +) / Double(reports.count)
        let lon = reports.map { $0.coordinate.value.longitude }.reduce(0, +) / Double(reports.count)
        return CLLocationCoordinate2D(latitude: lat, longitude: lon)
    }
}

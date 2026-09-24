import CoreLocation
import Foundation

enum IncidentSeverity: Int, Comparable {
    case low = 1
    case moderate = 2
    case high = 3
    case critical = 4

    static func < (lhs: IncidentSeverity, rhs: IncidentSeverity) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    /// Severity grows with corroborating report count, on top of whatever
    /// the category's base severity is.
    static func from(category: ReportCategory, reportCount: Int) -> IncidentSeverity {
        let base: IncidentSeverity = {
            switch category {
            case .fire, .crime: return .high
            case .medical: return .moderate
            default: return .low
            }
        }()
        let bump = min(reportCount / 3, 2)
        let level = min(base.rawValue + bump, IncidentSeverity.critical.rawValue)
        return IncidentSeverity(rawValue: level) ?? base
    }
}

/// A confirmed incident: the result of enough independent reports landing
/// near each other, close together in time. This is what actually shows up
/// as an alert marker on the map, as opposed to a single unverified report.
struct Incident: Identifiable, Equatable {
    let id: UUID
    var category: ReportCategory
    var coordinate: CLLocationCoordinate2D
    var reportIDs: [UUID]
    var firstReportedAt: Date
    var lastReportedAt: Date

    var reportCount: Int { reportIDs.count }
    var severity: IncidentSeverity { .from(category: category, reportCount: reportCount) }

    static func == (lhs: Incident, rhs: Incident) -> Bool {
        lhs.id == rhs.id
            && lhs.category == rhs.category
            && lhs.reportIDs == rhs.reportIDs
            && lhs.lastReportedAt == rhs.lastReportedAt
    }
}

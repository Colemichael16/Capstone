import SwiftUI

/// Category a user picks when filing a report. Drives icon, color, and how
/// aggressively similar reports get clustered into an Incident.
enum ReportCategory: String, CaseIterable, Identifiable, Codable {
    case safety = "Safety Concern"
    case medical = "Medical"
    case fire = "Fire / Smoke"
    case suspiciousActivity = "Suspicious Activity"
    case hazard = "Hazard"
    case crime = "Crime in Progress"
    case other = "Other"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .safety: return "exclamationmark.shield.fill"
        case .medical: return "cross.case.fill"
        case .fire: return "flame.fill"
        case .suspiciousActivity: return "eye.trianglebadge.exclamationmark.fill"
        case .hazard: return "exclamationmark.triangle.fill"
        case .crime: return "figure.run"
        case .other: return "questionmark.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .safety: return .orange
        case .medical: return .red
        case .fire: return .red
        case .suspiciousActivity: return .purple
        case .hazard: return .yellow
        case .crime: return .red
        case .other: return .gray
        }
    }

    /// Number of independent reports needed before this category escalates
    /// into a visible Incident. Serious categories escalate faster.
    var incidentThreshold: Int {
        switch self {
        case .fire, .crime, .medical: return 2
        case .safety, .suspiciousActivity, .hazard: return 3
        case .other: return 4
        }
    }
}

import CoreLocation
import SwiftUI

/// Matches shared/alert.schema.json exactly — keep these in sync. Mirrors
/// web/src/alerts/contract.js's enums/labels so both clients present alerts
/// identically.
enum AlertStatus: String, Decodable {
    case draft, active, updated, resolved, cancelled
}

enum AlertCategory: String, Decodable, CaseIterable {
    case activeThreat = "active_threat"
    case fire, weather, hazmat, police, utility, protest, medical

    var label: String {
        switch self {
        case .activeThreat: return "Active threat"
        case .fire: return "Fire"
        case .weather: return "Weather"
        case .hazmat: return "Hazmat"
        case .police: return "Police activity"
        case .utility: return "Utility outage"
        case .protest: return "Protest"
        case .medical: return "Medical"
        }
    }

    var systemImage: String {
        switch self {
        case .activeThreat: return "exclamationmark.triangle.fill"
        case .fire: return "flame.fill"
        case .weather: return "cloud.bolt.rain.fill"
        case .hazmat: return "exclamationmark.octagon.fill"
        case .police: return "figure.run"
        case .utility: return "bolt.slash.fill"
        case .protest: return "person.3.fill"
        case .medical: return "cross.case.fill"
        }
    }
}

enum AlertSeverity: String, Decodable, CaseIterable {
    case extreme, severe, moderate, minor

    var label: String {
        switch self {
        case .extreme: return "Extreme"
        case .severe: return "Severe"
        case .moderate: return "Moderate"
        case .minor: return "Minor"
        }
    }

    /// Same hex values as web/src/alerts/contract.js's SEVERITY_COLORS, so
    /// severity reads identically on both clients.
    var color: Color {
        switch self {
        case .extreme: return Color(red: 0.725, green: 0.110, blue: 0.110) // #b91c1c
        case .severe: return Color(red: 0.918, green: 0.345, blue: 0.047) // #ea580c
        case .moderate: return Color(red: 0.792, green: 0.541, blue: 0.016) // #ca8a04
        case .minor: return Color(red: 0.145, green: 0.388, blue: 0.922) // #2563eb
        }
    }
}

/// A dispatcher-issued alert, read from Supabase's `alerts_feed` view (or
/// `CampusAlert.sampleAlerts` offline). iOS never creates or edits one of these —
/// publishing is the web dispatcher's job (see web/src/components/Composer.jsx).
struct CampusAlert: Identifiable, Decodable, Equatable {
    let id: String
    let status: AlertStatus
    let category: AlertCategory
    let severity: AlertSeverity
    let headline: String
    let shortMessage: String
    let fullDetails: String?
    let instructions: String?
    let center: CLLocationCoordinate2D
    let radiusM: Int
    let issuedBy: String?
    let issuedAt: Date
    let expiresAt: Date

    /// Mirrors the "public reads active alerts" RLS policy / isActive() in
    /// web/src/alerts/contract.js.
    var isActive: Bool {
        (status == .active || status == .updated) && expiresAt > Date()
    }

    static func == (lhs: CampusAlert, rhs: CampusAlert) -> Bool {
        lhs.id == rhs.id && lhs.status == rhs.status && lhs.expiresAt == rhs.expiresAt
    }

    init(
        id: String,
        status: AlertStatus,
        category: AlertCategory,
        severity: AlertSeverity,
        headline: String,
        shortMessage: String,
        fullDetails: String?,
        instructions: String?,
        center: CLLocationCoordinate2D,
        radiusM: Int,
        issuedBy: String?,
        issuedAt: Date,
        expiresAt: Date
    ) {
        self.id = id
        self.status = status
        self.category = category
        self.severity = severity
        self.headline = headline
        self.shortMessage = shortMessage
        self.fullDetails = fullDetails
        self.instructions = instructions
        self.center = center
        self.radiusM = radiusM
        self.issuedBy = issuedBy
        self.issuedAt = issuedAt
        self.expiresAt = expiresAt
    }

    // Custom decoding: `center` arrives as a GeoJSON Point ({"type":"Point",
    // "coordinates":[lng,lat]}, per alert.schema.json), and timestamps are
    // ISO 8601 strings that may or may not carry fractional seconds —
    // decoded by hand rather than relying on whatever date strategy the
    // Supabase client's JSONDecoder happens to be configured with.
    enum CodingKeys: String, CodingKey {
        case id, status, category, severity, headline, instructions, center
        case shortMessage = "short_message"
        case fullDetails = "full_details"
        case radiusM = "radius_m"
        case issuedBy = "issued_by"
        case issuedAt = "issued_at"
        case expiresAt = "expires_at"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        status = try container.decode(AlertStatus.self, forKey: .status)
        category = try container.decode(AlertCategory.self, forKey: .category)
        severity = try container.decode(AlertSeverity.self, forKey: .severity)
        headline = try container.decode(String.self, forKey: .headline)
        shortMessage = try container.decode(String.self, forKey: .shortMessage)
        fullDetails = try container.decodeIfPresent(String.self, forKey: .fullDetails)
        instructions = try container.decodeIfPresent(String.self, forKey: .instructions)
        center = try container.decode(GeoJSONPoint.self, forKey: .center).coordinate
        radiusM = try container.decode(Int.self, forKey: .radiusM)
        issuedBy = try container.decodeIfPresent(String.self, forKey: .issuedBy)

        let issuedAtString = try container.decode(String.self, forKey: .issuedAt)
        let expiresAtString = try container.decode(String.self, forKey: .expiresAt)
        guard let issued = Self.parseTimestamp(issuedAtString), let expires = Self.parseTimestamp(expiresAtString) else {
            throw DecodingError.dataCorruptedError(
                forKey: .issuedAt,
                in: container,
                debugDescription: "Unparseable timestamp"
            )
        }
        issuedAt = issued
        expiresAt = expires
    }

    private static let isoWithFractionalSeconds: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    private static let isoWithoutFractionalSeconds: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter
    }()

    private static func parseTimestamp(_ string: String) -> Date? {
        isoWithFractionalSeconds.date(from: string) ?? isoWithoutFractionalSeconds.date(from: string)
    }
}

private struct GeoJSONPoint: Decodable {
    let coordinates: [Double]

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: coordinates[1], longitude: coordinates[0])
    }
}

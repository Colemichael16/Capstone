import CoreLocation
import Foundation

/// Talks to `/api/reports` on the db/ backend. See shared/api-contract.md.
/// Swapped in for `InMemoryReportRepository` when `AppConfig.useRemoteBackend`
/// is true — `ReportStore` doesn't know or care which one it's holding.
final class RemoteReportRepository: ReportRepository {
    private let client: APIClient

    init(client: APIClient) {
        self.client = client
    }

    func fetchAll() async -> [Report] {
        guard let response: ReportsResponse = try? await client.request("/api/reports", requiresAuth: true) else {
            return []
        }
        return response.reports.map(\.asReport)
    }

    func save(_ report: Report) async {
        let body = CreateReportRequest(
            category: report.category.rawValue,
            latitude: report.coordinate.value.latitude,
            longitude: report.coordinate.value.longitude,
            note: report.note
        )
        let _: ReportResponse? = try? await client.request("/api/reports", method: "POST", body: body, requiresAuth: true)
    }
}

private struct ReportsResponse: Decodable { let reports: [RemoteReport] }
private struct ReportResponse: Decodable { let report: RemoteReport }

private struct CreateReportRequest: Encodable {
    let category: String
    let latitude: Double
    let longitude: Double
    let note: String
}

private struct RemoteReport: Decodable {
    let id: String
    let category: String
    let latitude: Double
    let longitude: Double
    let note: String
    let createdAt: Date

    var asReport: Report {
        Report(
            id: UUID(uuidString: id) ?? UUID(),
            category: ReportCategory(rawValue: category) ?? .other,
            coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
            note: note,
            createdAt: createdAt
        )
    }
}

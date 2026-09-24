import Foundation

/// Storage boundary for reports. `InMemoryReportRepository` is the
/// prototype implementation; once `db/` has a real backend, add a
/// `RemoteReportRepository: ReportRepository` that talks to it and swap it
/// in at the call site in `CUAlertsApp` — nothing else has to change.
protocol ReportRepository {
    func fetchAll() async -> [Report]
    func save(_ report: Report) async
}

actor InMemoryReportRepository: ReportRepository {
    private var reports: [Report] = []

    func fetchAll() async -> [Report] {
        reports
    }

    func save(_ report: Report) async {
        reports.append(report)
    }
}

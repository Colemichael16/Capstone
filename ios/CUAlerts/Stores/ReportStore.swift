import CoreLocation
import Foundation

/// App-wide source of truth for reports and the incidents derived from
/// them. Views read `reports`/`incidents`; the only way to add data is
/// `fileReport`, which persists it and re-clusters.
@MainActor
final class ReportStore: ObservableObject {
    @Published private(set) var reports: [Report] = []
    @Published private(set) var incidents: [Incident] = []

    private let repository: ReportRepository

    init(repository: ReportRepository = InMemoryReportRepository()) {
        self.repository = repository
    }

    func load() async {
        reports = await repository.fetchAll()
        recomputeIncidents()
    }

    @discardableResult
    func fileReport(category: ReportCategory, coordinate: CLLocationCoordinate2D, note: String) async -> Report {
        let report = Report(category: category, coordinate: coordinate, note: note)
        await repository.save(report)
        reports.append(report)
        recomputeIncidents()
        return report
    }

    /// Reports that haven't (yet) crossed the threshold to become part of
    /// an incident — still worth showing on the map as low-key markers.
    var unclusteredReports: [Report] {
        let clusteredIDs = Set(incidents.flatMap(\.reportIDs))
        return reports.filter { !clusteredIDs.contains($0.id) }
    }

    private func recomputeIncidents() {
        incidents = IncidentClusterer.buildIncidents(from: reports)
    }
}

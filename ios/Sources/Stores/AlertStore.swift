import Foundation

/// App-wide source of truth for active alerts. Loads once on `start()` and
/// (when backed by Supabase) re-loads automatically on every Realtime
/// change, so the map stays live without the user doing anything.
@MainActor
final class AlertStore: ObservableObject {
    @Published private(set) var alerts: [CampusAlert] = []
    @Published private(set) var isLoading = false
    @Published var errorMessage: String?

    private let repository: AlertRepository
    private var realtimeTask: Task<Void, Never>?

    init(repository: AlertRepository = SupabaseConfig.isConfigured
            ? SupabaseAlertRepository()
            : OfflineAlertRepository()) {
        self.repository = repository
    }

    func start() async {
        await load()
        if let supabaseRepository = repository as? SupabaseAlertRepository, realtimeTask == nil {
            realtimeTask = supabaseRepository.observeChanges { [weak self] in
                Task { await self?.load() }
            }
        }
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }

        do {
            alerts = try await repository.fetchActiveAlerts()
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    deinit {
        realtimeTask?.cancel()
    }
}

import Foundation
import Supabase

protocol AlertRepository {
    func fetchActiveAlerts() async throws -> [CampusAlert]
}

/// Used when `SupabaseConfig.isConfigured` is false — the same fallback the
/// web app uses when its own Supabase env vars are unset (see
/// web/src/supabase.js).
struct OfflineAlertRepository: AlertRepository {
    func fetchActiveAlerts() async throws -> [CampusAlert] {
        CampusAlert.sampleAlerts
    }
}

/// Reads from `alerts_feed` (the contract-shaped view) and can watch the
/// raw `alerts` table for Realtime changes. Mirrors
/// web/src/alerts/api.js and the Swift snippet in db/README.md exactly —
/// this is the documented shape of the intended iOS client, not a guess.
final class SupabaseAlertRepository: AlertRepository {
    private let client: SupabaseClient

    init(client: SupabaseClient = SupabaseClient(
        supabaseURL: URL(string: SupabaseConfig.url)!,
        supabaseKey: SupabaseConfig.publishableKey
    )) {
        self.client = client
    }

    func fetchActiveAlerts() async throws -> [CampusAlert] {
        try await client
            .from("alerts_feed")
            .select()
            .in("status", values: ["active", "updated"])
            .gt("expires_at", value: Date())
            .order("issued_at", ascending: false)
            .execute()
            .value
    }

    /// Fires `onChange` on any insert/update/delete the signed-in session
    /// can see under RLS. The caller is expected to re-fetch
    /// `fetchActiveAlerts()` in response, same as the web client does.
    func observeChanges(onChange: @escaping () -> Void) -> Task<Void, Never> {
        Task {
            let channel = client.channel("alerts")
            let changes = channel.postgresChange(AnyAction.self, schema: "public", table: "alerts")
            await channel.subscribe()
            for await _ in changes {
                onChange()
            }
        }
    }
}

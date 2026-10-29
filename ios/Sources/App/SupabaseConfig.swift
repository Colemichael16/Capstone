import Foundation

/// Mirrors web/.env.example. Leave both blank to run entirely offline on
/// `CampusAlert.sampleAlerts` — the same fallback the web app uses when its
/// own env vars are unset. Fill in real values once a Supabase project
/// exists (Project Settings > API Keys — the publishable/anon key only,
/// never service_role); see db/README.md for the Supabase setup.
///
/// These are placeholders, not secrets — don't put a real key directly in
/// this file if it's going to be committed. Swap this for values loaded
/// from an untracked config (an .xcconfig, or a gitignored Secrets.swift)
/// before this app handles anything real.
enum SupabaseConfig {
    static let url = ""
    static let publishableKey = ""

    static var isConfigured: Bool { !url.isEmpty && !publishableKey.isEmpty }
}

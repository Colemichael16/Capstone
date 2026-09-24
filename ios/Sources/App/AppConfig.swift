import Foundation

enum AppConfig {
    /// The db/ backend's base URL. Defaults to a local server for
    /// development — see db/README.md to run one.
    static let apiBaseURL = URL(string: "http://localhost:3000")!

    /// Off by default so the app runs standalone with seeded sample data
    /// even when no backend is running. Flip to true once `db/` is running
    /// and you want real auth + persisted reports (see ios/README.md).
    static let useRemoteBackend = false
}

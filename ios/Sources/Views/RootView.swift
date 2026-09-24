import SwiftUI

/// Decides between the sign-in flow and the main app, and (re)loads
/// reports whenever that decision changes — covers both the standalone
/// demo mode (loads immediately) and the real-backend mode (loads once
/// signed in, and again after a fresh login).
struct RootView: View {
    @EnvironmentObject private var authStore: AuthStore
    @EnvironmentObject private var reportStore: ReportStore

    private var isReady: Bool {
        !AppConfig.useRemoteBackend || authStore.isAuthenticated
    }

    var body: some View {
        Group {
            if isReady {
                ContentView()
            } else {
                LoginView()
            }
        }
        .task(id: isReady) {
            if isReady {
                await reportStore.load()
            }
        }
    }
}

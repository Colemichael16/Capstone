import SwiftUI

@main
struct CUAlertsApp: App {
    @StateObject private var authStore: AuthStore
    @StateObject private var reportStore: ReportStore
    @StateObject private var locationManager = LocationManager()

    init() {
        let auth = AuthStore()
        _authStore = StateObject(wrappedValue: auth)
        _reportStore = StateObject(wrappedValue: ReportStore(
            repository: AppConfig.useRemoteBackend
                ? RemoteReportRepository(client: auth.client)
                : InMemoryReportRepository()
        ))
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authStore)
                .environmentObject(reportStore)
                .environmentObject(locationManager)
                .task {
                    locationManager.requestPermission()
                }
        }
    }
}

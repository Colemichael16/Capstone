import SwiftUI

@main
struct CUAlertsApp: App {
    @StateObject private var reportStore = ReportStore()
    @StateObject private var locationManager = LocationManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(reportStore)
                .environmentObject(locationManager)
                .task {
                    await reportStore.load()
                    locationManager.requestPermission()
                }
        }
    }
}

import SwiftUI

@main
struct CUAlertsApp: App {
    @StateObject private var alertStore = AlertStore()
    @StateObject private var locationManager = LocationManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(alertStore)
                .environmentObject(locationManager)
                .task {
                    locationManager.requestPermission()
                    await alertStore.start()
                }
        }
    }
}

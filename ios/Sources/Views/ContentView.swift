import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            CampusMapView()
                .tabItem { Label("Campus Map", systemImage: "map.fill") }

            DirectionsView()
                .tabItem { Label("Directions", systemImage: "arrow.triangle.turn.up.right.diamond.fill") }

            if AppConfig.useRemoteBackend {
                AccountView()
                    .tabItem { Label("Account", systemImage: "person.circle.fill") }
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(ReportStore())
        .environmentObject(LocationManager())
        .environmentObject(AuthStore())
}

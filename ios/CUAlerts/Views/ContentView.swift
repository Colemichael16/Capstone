import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            CampusMapView()
                .tabItem { Label("Campus Map", systemImage: "map.fill") }

            DirectionsView()
                .tabItem { Label("Directions", systemImage: "arrow.triangle.turn.up.right.diamond.fill") }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(ReportStore())
        .environmentObject(LocationManager())
}

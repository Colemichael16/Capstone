import SwiftUI

struct ContentView: View {
    @State private var selectedTab: AppTab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(selectedTab: $selectedTab)
                .tabItem { Label("Home", systemImage: "house.fill") }
                .tag(AppTab.home)

            AlertsListView()
                .tabItem { Label("Alerts", systemImage: "bell.fill") }
                .tag(AppTab.alerts)

            CampusMapView()
                .tabItem { Label("Map", systemImage: "map.fill") }
                .tag(AppTab.map)

            MoreView()
                .tabItem { Label("More", systemImage: "ellipsis") }
                .tag(AppTab.more)
        }
        .tint(Theme.cuGold)
    }
}

#Preview {
    ContentView()
        .environmentObject(AlertStore())
        .environmentObject(LocationManager())
}

import SwiftUI

struct MoreView: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink {
                    DirectionsView()
                } label: {
                    Label("Directions", systemImage: "arrow.triangle.turn.up.right.diamond.fill")
                }

                NavigationLink {
                    LocalInfoView()
                } label: {
                    Label("Local Information", systemImage: "info.circle.fill")
                }
            }
            .navigationTitle("More")
        }
    }
}

#Preview {
    MoreView()
        .environmentObject(LocationManager())
}

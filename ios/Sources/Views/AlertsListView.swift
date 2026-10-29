import SwiftUI

/// A flat, chronological list of every active alert — the same data as the
/// map, just scannable without having to tap pins.
struct AlertsListView: View {
    @EnvironmentObject private var alertStore: AlertStore

    @State private var selectedAlert: CampusAlert?

    private var sortedAlerts: [CampusAlert] {
        alertStore.alerts.sorted { $0.issuedAt > $1.issuedAt }
    }

    var body: some View {
        NavigationStack {
            Group {
                if sortedAlerts.isEmpty {
                    ContentUnavailableView(
                        "No Active Alerts",
                        systemImage: "checkmark.shield",
                        description: Text("You'll see official campus alerts here as they're issued.")
                    )
                } else {
                    List(sortedAlerts) { alert in
                        Button {
                            selectedAlert = alert
                        } label: {
                            AlertRow(alert: alert)
                        }
                        .buttonStyle(.plain)
                    }
                    .listStyle(.plain)
                    .refreshable {
                        await alertStore.load()
                    }
                }
            }
            .navigationTitle("Alerts")
            .sheet(item: $selectedAlert) { alert in
                AlertDetailView(alert: alert)
            }
        }
    }
}

private struct AlertRow: View {
    let alert: CampusAlert

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: alert.category.systemImage)
                .font(.headline)
                .foregroundStyle(.white)
                .padding(8)
                .background(alert.severity.color, in: Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(alert.headline)
                    .font(.subheadline.bold())
                Text(alert.shortMessage)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
                Text(alert.issuedAt.formatted(.relative(presentation: .named)))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            Spacer()
        }
        .padding(.vertical, 6)
    }
}

#Preview {
    AlertsListView()
        .environmentObject(AlertStore())
}

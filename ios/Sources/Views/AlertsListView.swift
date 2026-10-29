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
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(sortedAlerts) { alert in
                                Button {
                                    selectedAlert = alert
                                } label: {
                                    AlertRow(alert: alert)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding()
                    }
                    .background(Color(.systemGroupedBackground))
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
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle()
                    .fill(Theme.gradient(for: alert.severity.color))
                    .frame(width: 44, height: 44)
                Image(systemName: alert.category.systemImage)
                    .font(.headline)
                    .foregroundStyle(.white)
            }

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

            Image(systemName: "chevron.right")
                .font(.caption.bold())
                .foregroundStyle(.tertiary)
        }
        .padding(14)
        .cardStyle()
    }
}

#Preview {
    AlertsListView()
        .environmentObject(AlertStore())
}

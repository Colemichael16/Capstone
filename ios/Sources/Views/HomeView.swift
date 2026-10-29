import SwiftUI

enum AppTab: Hashable {
    case home, alerts, map, more
}

/// The landing screen: the most urgent active alert front and center (or an
/// all-clear state), plus quick access to the rest of the app — matches the
/// "Prominent Alert" / "Quick Access" layout from the project deck.
struct HomeView: View {
    @EnvironmentObject private var alertStore: AlertStore
    @Binding var selectedTab: AppTab

    @State private var selectedAlert: CampusAlert?
    @State private var showingSafetyTips = false

    /// Most severe, most recently issued active alert — the one worth
    /// leading with.
    private var headlineAlert: CampusAlert? {
        alertStore.alerts
            .sorted { lhs, rhs in
                if lhs.severity != rhs.severity { return severityRank(lhs.severity) > severityRank(rhs.severity) }
                return lhs.issuedAt > rhs.issuedAt
            }
            .first
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    header

                    if let headlineAlert {
                        AlertBanner(alert: headlineAlert) { selectedAlert = headlineAlert }
                    } else {
                        allClearBanner
                    }

                    quickAccessGrid
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
            .navigationBarHidden(true)
            .sheet(item: $selectedAlert) { alert in
                AlertDetailView(alert: alert)
            }
            .sheet(isPresented: $showingSafetyTips) {
                SafetyTipsView()
            }
        }
    }

    private var header: some View {
        HStack {
            HStack(spacing: 6) {
                Text("Regent")
                    .foregroundStyle(Theme.cuBlack)
                Text("Watch")
                    .foregroundStyle(Theme.cuGold)
            }
            .font(.title2.bold())

            Spacer()

            Image(systemName: "gearshape")
                .font(.title3)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 8)
    }

    private var allClearBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.shield.fill")
                .font(.title2)
                .foregroundStyle(Theme.safeZone)
            VStack(alignment: .leading, spacing: 2) {
                Text("No Active Alerts")
                    .font(.headline)
                Text("You'll be notified here if something comes up.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding()
        .background(Theme.safeZone.opacity(0.1), in: RoundedRectangle(cornerRadius: 16))
    }

    private var quickAccessGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            QuickAccessButton(title: "Campus Map", systemImage: "map.fill") {
                selectedTab = .map
            }
            QuickAccessButton(title: "Safety Tips", systemImage: "checkmark.shield") {
                showingSafetyTips = true
            }
            QuickAccessButton(title: "Directions", systemImage: "arrow.triangle.turn.up.right.diamond.fill") {
                selectedTab = .more
            }
            QuickAccessButton(title: "Resources", systemImage: "info.circle.fill") {
                selectedTab = .more
            }
        }
    }

    private func severityRank(_ severity: AlertSeverity) -> Int {
        switch severity {
        case .extreme: return 3
        case .severe: return 2
        case .moderate: return 1
        case .minor: return 0
        }
    }
}

private struct AlertBanner: View {
    let alert: CampusAlert
    let onViewDetails: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 10) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.title3)
                VStack(alignment: .leading, spacing: 2) {
                    Text("EMERGENCY ALERT")
                        .font(.caption.bold())
                    Text(alert.headline)
                        .font(.subheadline.bold())
                }
                Spacer()
            }
            .foregroundStyle(.white)
            .padding(14)
            .background(alert.severity.color)

            VStack(alignment: .leading, spacing: 8) {
                Text(alert.shortMessage)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                Text("Updated \(alert.issuedAt.formatted(.relative(presentation: .named)))")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Button("View Details →", action: onViewDetails)
                    .font(.subheadline.bold())
                    .foregroundStyle(alert.severity.color)
            }
            .padding(14)
            .background(alert.severity.color.opacity(0.1))
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

private struct QuickAccessButton: View {
    let title: String
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: systemImage)
                    .font(.title2)
                    .foregroundStyle(Theme.cuGold)
                Text(title)
                    .font(.subheadline.bold())
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HomeView(selectedTab: .constant(.home))
        .environmentObject(AlertStore())
}

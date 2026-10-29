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
                VStack(alignment: .leading, spacing: 24) {
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
            .background(Color(.systemGroupedBackground))
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
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(Theme.goldGradient)
                    .frame(width: 40, height: 40)
                Image(systemName: "bell.badge.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Theme.cuBlack)
            }
            .subtleShadow()

            HStack(spacing: 6) {
                Text("Regent")
                    .foregroundStyle(Theme.cuBlack)
                Text("Watch")
                    .foregroundStyle(Theme.cuGoldDark)
            }
            .font(.title2.bold())

            Spacer()

            Image(systemName: "gearshape.fill")
                .font(.title3)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 8)
    }

    private var allClearBanner: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Theme.gradient(for: Theme.safeZone))
                    .frame(width: 48, height: 48)
                Image(systemName: "checkmark.shield.fill")
                    .font(.title3)
                    .foregroundStyle(.white)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text("No Active Alerts")
                    .font(.headline)
                Text("You'll be notified here if something comes up.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(16)
        .cardStyle(fill: Theme.safeZone.opacity(0.08))
    }

    private var quickAccessGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
            QuickAccessButton(title: "Campus Map", systemImage: "map.fill", tint: Theme.resource) {
                selectedTab = .map
            }
            QuickAccessButton(title: "Safety Tips", systemImage: "checkmark.shield.fill", tint: Theme.safeZone) {
                showingSafetyTips = true
            }
            QuickAccessButton(title: "Directions", systemImage: "arrow.triangle.turn.up.right.diamond.fill", tint: Theme.cuGoldDark) {
                selectedTab = .more
            }
            QuickAccessButton(title: "Resources", systemImage: "info.circle.fill", tint: Theme.resource) {
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
                        .tracking(0.5)
                    Text(alert.headline)
                        .font(.subheadline.bold())
                }
                Spacer()
            }
            .foregroundStyle(.white)
            .padding(16)
            .background(Theme.gradient(for: alert.severity.color))

            VStack(alignment: .leading, spacing: 10) {
                Text(alert.shortMessage)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                Text("Updated \(alert.issuedAt.formatted(.relative(presentation: .named)))")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Button(action: onViewDetails) {
                    HStack(spacing: 4) {
                        Text("View Details")
                        Image(systemName: "arrow.right")
                    }
                    .font(.subheadline.bold())
                }
                .buttonStyle(.plain)
                .foregroundStyle(alert.severity.color)
            }
            .padding(16)
            .background(Color(.secondarySystemBackground))
        }
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: alert.severity.color.opacity(0.25), radius: 16, x: 0, y: 8)
    }
}

private struct QuickAccessButton: View {
    let title: String
    let systemImage: String
    let tint: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(Theme.gradient(for: tint))
                        .frame(width: 48, height: 48)
                    Image(systemName: systemImage)
                        .font(.system(size: 19, weight: .semibold))
                        .foregroundStyle(.white)
                }
                Text(title)
                    .font(.subheadline.bold())
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 22)
            .cardStyle(cornerRadius: 16)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HomeView(selectedTab: .constant(.home))
        .environmentObject(AlertStore())
}

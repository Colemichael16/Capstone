import SwiftUI

struct MoreView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    NavigationLink {
                        DirectionsView()
                    } label: {
                        MoreRow(title: "Directions", subtitle: "Walking routes and emergency routing", systemImage: "arrow.triangle.turn.up.right.diamond.fill", tint: Theme.cuGoldDark)
                    }
                    .buttonStyle(.plain)

                    NavigationLink {
                        LocalInfoView()
                    } label: {
                        MoreRow(title: "Local Information", subtitle: "Events, resources, and safety tips", systemImage: "info.circle.fill", tint: Theme.resource)
                    }
                    .buttonStyle(.plain)
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("More")
        }
    }
}

private struct MoreRow: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let tint: Color

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Theme.gradient(for: tint))
                    .frame(width: 44, height: 44)
                Image(systemName: systemImage)
                    .font(.headline)
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.subheadline.bold())
                Text(subtitle).font(.footnote).foregroundStyle(.secondary)
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
    MoreView()
        .environmentObject(LocationManager())
}

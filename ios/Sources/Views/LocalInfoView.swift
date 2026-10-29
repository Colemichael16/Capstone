import SwiftUI

/// Matches the "Local Information" mockup: a segmented picker over
/// Events / Resources / Safety Tips, each a list of cards. Static sample
/// content for now — see LocalInfoSamples.swift.
struct LocalInfoView: View {
    @State private var category: LocalInfoCategory = .events

    var body: some View {
        VStack(spacing: 0) {
            Picker("Category", selection: $category) {
                ForEach(LocalInfoCategory.allCases, id: \.self) { category in
                    Text(category.rawValue).tag(category)
                }
            }
            .pickerStyle(.segmented)
            .padding()

            ScrollView {
                VStack(spacing: 12) {
                    ForEach(LocalInfoSamples.items(for: category)) { item in
                        LocalInfoRow(item: item)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 16)
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Local Information")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct LocalInfoRow: View {
    let item: LocalInfoItem

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle()
                    .fill(Theme.gradient(for: item.tintColor))
                    .frame(width: 40, height: 40)
                Image(systemName: item.systemImage)
                    .font(.subheadline.bold())
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(item.title).font(.subheadline.bold())
                Text(item.detail)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                if !item.timestamp.isEmpty {
                    Text(item.timestamp)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }

            Spacer()

            if item.hasChevron {
                Image(systemName: "chevron.right")
                    .font(.caption.bold())
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(14)
        .cardStyle()
    }
}

#Preview {
    NavigationStack { LocalInfoView() }
}

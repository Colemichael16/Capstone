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

            List(LocalInfoSamples.items(for: category)) { item in
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: item.systemImage)
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(width: 32, height: 32)
                        .background(item.tintColor, in: Circle())

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
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
                .padding(.vertical, 4)
            }
            .listStyle(.plain)
        }
        .navigationTitle("Local Information")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack { LocalInfoView() }
}

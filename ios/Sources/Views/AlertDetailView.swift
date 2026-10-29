import SwiftUI

struct AlertDetailView: View {
    let alert: CampusAlert

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Label(alert.category.label, systemImage: alert.category.systemImage)
                        .font(.headline)
                        .foregroundStyle(alert.severity.color)
                    Text(alert.severity.label)
                        .font(.subheadline.bold())
                        .foregroundStyle(alert.severity.color)
                }

                Section("Message") {
                    Text(alert.shortMessage)
                    if let instructions = alert.instructions, !instructions.isEmpty {
                        Text(instructions)
                            .foregroundStyle(.secondary)
                    }
                }

                if let fullDetails = alert.fullDetails, !fullDetails.isEmpty {
                    Section("Details") {
                        Text(fullDetails)
                    }
                }

                Section("Timing") {
                    LabeledContent("Issued", value: alert.issuedAt.formatted(date: .omitted, time: .shortened))
                    LabeledContent("Expires", value: alert.expiresAt.formatted(date: .omitted, time: .shortened))
                }
            }
            .navigationTitle(alert.headline)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

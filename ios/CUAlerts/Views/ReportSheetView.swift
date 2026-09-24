import CoreLocation
import SwiftUI

/// Form for filing a report at a specific coordinate the user picked on the
/// map. Kept deliberately short: category + optional note, submit.
struct ReportSheetView: View {
    let coordinate: CLLocationCoordinate2D
    let onDone: () -> Void

    @EnvironmentObject private var reportStore: ReportStore
    @State private var category: ReportCategory = .safety
    @State private var note: String = ""
    @State private var isSubmitting = false

    var body: some View {
        NavigationStack {
            Form {
                Section("What are you seeing?") {
                    Picker("Category", selection: $category) {
                        ForEach(ReportCategory.allCases) { category in
                            Label(category.rawValue, systemImage: category.systemImage)
                                .tag(category)
                        }
                    }
                    .pickerStyle(.inline)
                }

                Section("Details (optional)") {
                    TextField("What's happening?", text: $note, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section {
                    Text("Reports are anonymous. Once enough people report the same thing nearby, it becomes a visible incident on the map.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("File a Report")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onDone)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Submit") {
                        submit()
                    }
                    .disabled(isSubmitting)
                }
            }
        }
    }

    private func submit() {
        isSubmitting = true
        Task {
            await reportStore.fileReport(category: category, coordinate: coordinate, note: note)
            isSubmitting = false
            onDone()
        }
    }
}

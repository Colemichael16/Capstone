import SwiftUI

struct IncidentDetailView: View {
    let incident: Incident

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Label(incident.category.rawValue, systemImage: incident.category.systemImage)
                        .font(.title3.bold())
                        .foregroundStyle(incident.category.color)
                }

                Section("Status") {
                    LabeledContent("Reports", value: "\(incident.reportCount)")
                    LabeledContent("Severity", value: severityLabel)
                    LabeledContent("First reported", value: incident.firstReportedAt.formatted(date: .omitted, time: .shortened))
                    LabeledContent("Last update", value: incident.lastReportedAt.formatted(date: .omitted, time: .shortened))
                }

                Section {
                    Text("This location has multiple independent reports of the same issue in the last 45 minutes. If you're nearby and it's an emergency, use the Directions tab to route to the nearest emergency resource or call 911.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Active Incident")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private var severityLabel: String {
        switch incident.severity {
        case .low: return "Low"
        case .moderate: return "Moderate"
        case .high: return "High"
        case .critical: return "Critical"
        }
    }
}

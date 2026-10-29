import MapKit
import SwiftUI

struct AlertDetailView: View {
    let alert: CampusAlert

    @Environment(\.dismiss) private var dismiss
    @State private var cameraPosition: MapCameraPosition

    init(alert: CampusAlert) {
        self.alert = alert
        _cameraPosition = State(initialValue: .region(
            MKCoordinateRegion(center: alert.center, latitudinalMeters: Double(alert.radiusM) * 4, longitudinalMeters: Double(alert.radiusM) * 4)
        ))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    statusBanner

                    VStack(alignment: .leading, spacing: 8) {
                        Text("What is happening?")
                            .font(.headline)
                        Text(alert.fullDetails?.isEmpty == false ? alert.fullDetails! : alert.shortMessage)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    if let instructions = alert.instructions, !instructions.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("What should I do?")
                                .font(.headline)
                            Text(instructions)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }

                    miniMap
                        .frame(height: 180)
                        .clipShape(RoundedRectangle(cornerRadius: 12))

                    VStack(alignment: .leading, spacing: 4) {
                        LabeledContent("Issued", value: alert.issuedAt.formatted(date: .omitted, time: .shortened))
                        LabeledContent("Expires", value: alert.expiresAt.formatted(date: .omitted, time: .shortened))
                    }
                    .font(.footnote)
                }
                .padding()
            }
            .navigationTitle("Alert Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private var statusBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: alert.category.systemImage)
                .font(.title3)
            VStack(alignment: .leading, spacing: 2) {
                Text(alert.headline)
                    .font(.subheadline.bold())
                Text("\(alert.status == .active ? "Active" : "Updated") · \(alert.issuedAt.formatted(.relative(presentation: .named)))")
                    .font(.caption)
            }
            Spacer()
        }
        .foregroundStyle(.white)
        .padding(14)
        .background(alert.severity.color, in: RoundedRectangle(cornerRadius: 12))
    }

    private var miniMap: some View {
        Map(position: $cameraPosition, interactionModes: []) {
            MapCircle(center: alert.center, radius: Double(alert.radiusM))
                .foregroundStyle(alert.severity.color.opacity(0.18))
                .stroke(alert.severity.color, lineWidth: 2)

            Marker(alert.headline, coordinate: alert.center)
                .tint(alert.severity.color)
        }
    }
}

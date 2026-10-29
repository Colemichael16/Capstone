import SwiftUI

struct SafetyTipsView: View {
    @Environment(\.dismiss) private var dismiss

    private let tips: [(title: String, body: String, systemImage: String)] = [
        ("Save CU Police", "Save CU Police's non-emergency line in your phone: 303-492-6666. For an emergency, always call 911 first.", "phone.fill"),
        ("Share your location", "Let a friend know where you're headed on campus at night, especially walking alone.", "location.fill"),
        ("Know your nearest safe zone", "Check the Map tab for the closest safe zone — CU Police or Wardenburg Health Center — before you need it.", "checkmark.shield.fill"),
        ("Sign up for CU Alerts", "RegentWatch shows official alerts, but CU's own emergency text/email system is still the fastest way to get notified.", "bell.badge.fill"),
        ("Use the emergency blue light phones", "Blue light emergency phones are stationed across campus and connect directly to CU Police.", "light.beacon.max.fill"),
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(tips, id: \.title) { tip in
                        HStack(alignment: .top, spacing: 14) {
                            ZStack {
                                Circle()
                                    .fill(Theme.goldGradient)
                                    .frame(width: 40, height: 40)
                                Image(systemName: tip.systemImage)
                                    .font(.subheadline.bold())
                                    .foregroundStyle(Theme.cuBlack)
                            }
                            VStack(alignment: .leading, spacing: 2) {
                                Text(tip.title).font(.subheadline.bold())
                                Text(tip.body).font(.footnote).foregroundStyle(.secondary)
                            }
                            Spacer()
                        }
                        .padding(14)
                        .cardStyle()
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Safety Tips")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

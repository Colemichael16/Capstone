import SwiftUI

enum LocalInfoCategory: String, CaseIterable, Hashable {
    case events = "Events"
    case resources = "Resources"
    case safetyTips = "Safety Tips"
}

struct LocalInfoItem: Identifiable {
    let id = UUID()
    let title: String
    let detail: String
    let timestamp: String
    let systemImage: String
    let tintColor: Color
    let hasChevron: Bool
}

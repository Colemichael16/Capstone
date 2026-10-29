import SwiftUI

/// Static placeholder content matching the "Local Information" screen in
/// the project deck (Campus Closure / RC Events / Weather / Transit).
/// There's no real data source for any of this yet — swap for a live feed
/// (campus events API, CU transit status, etc.) before this ships.
enum LocalInfoSamples {
    static let events: [LocalInfoItem] = [
        LocalInfoItem(
            title: "Campus Closure",
            detail: "Main campus closed due to weather conditions.",
            timestamp: "Today, 10:00 AM",
            systemImage: "exclamationmark.triangle.fill",
            tintColor: .red,
            hasChevron: false
        ),
        LocalInfoItem(
            title: "RC Events: Winter Career Fair",
            detail: "UCEN",
            timestamp: "Tomorrow, 11:00 AM",
            systemImage: "calendar",
            tintColor: Theme.resource,
            hasChevron: true
        ),
        LocalInfoItem(
            title: "Weather Update",
            detail: "Snow expected this evening. Check travel conditions.",
            timestamp: "Today, 9:00 AM",
            systemImage: "cloud.fill",
            tintColor: Theme.resource,
            hasChevron: true
        ),
        LocalInfoItem(
            title: "Transit Information",
            detail: "Some routes experiencing delays due to weather.",
            timestamp: "Today, 8:45 AM",
            systemImage: "bus.fill",
            tintColor: Theme.resource,
            hasChevron: true
        ),
    ]

    static let resources: [LocalInfoItem] = [
        LocalInfoItem(
            title: "CU Police Department",
            detail: "Non-emergency: 303-492-6666 • Emergency: 911",
            timestamp: "24/7",
            systemImage: "shield.fill",
            tintColor: Theme.safeZone,
            hasChevron: false
        ),
        LocalInfoItem(
            title: "Wardenburg Health Center",
            detail: "Urgent & primary care for students",
            timestamp: "Mon–Fri, 8 AM–5 PM",
            systemImage: "cross.case.fill",
            tintColor: Theme.safeZone,
            hasChevron: false
        ),
        LocalInfoItem(
            title: "Counseling and Psychiatric Services",
            detail: "Free, confidential support for CU students",
            timestamp: "303-492-2277",
            systemImage: "heart.fill",
            tintColor: Theme.resource,
            hasChevron: false
        ),
    ]

    static let safetyTips: [LocalInfoItem] = [
        LocalInfoItem(
            title: "Know your nearest safe zone",
            detail: "Check the Map tab before you need it.",
            timestamp: "",
            systemImage: "checkmark.shield.fill",
            tintColor: Theme.safeZone,
            hasChevron: false
        ),
        LocalInfoItem(
            title: "Share your location",
            detail: "Let a friend know where you're headed at night.",
            timestamp: "",
            systemImage: "location.fill",
            tintColor: Theme.resource,
            hasChevron: false
        ),
        LocalInfoItem(
            title: "Use blue light phones",
            detail: "Stationed across campus, connect directly to CU Police.",
            timestamp: "",
            systemImage: "light.beacon.max.fill",
            tintColor: Theme.resource,
            hasChevron: false
        ),
    ]

    static func items(for category: LocalInfoCategory) -> [LocalInfoItem] {
        switch category {
        case .events: return events
        case .resources: return resources
        case .safetyTips: return safetyTips
        }
    }
}

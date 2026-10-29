import SwiftUI

/// CU Boulder brand colors (official CU Gold / Black) plus the small set of
/// shared design tokens (gradient, card elevation) used to keep every
/// screen feeling like one system instead of a pile of flat SwiftUI
/// defaults. Alert severity colors stay separate (`AlertSeverity.color`)
/// — those are a cross-client contract with web/src/alerts/contract.js and
/// shouldn't shift for branding reasons.
enum Theme {
    static let cuGold = Color(red: 0.812, green: 0.722, blue: 0.486) // #CFB87C
    static let cuGoldLight = Color(red: 0.910, green: 0.812, blue: 0.588) // #E8CF95
    static let cuGoldDark = Color(red: 0.588, green: 0.471, blue: 0.251) // #967840
    static let cuBlack = Color(red: 0.063, green: 0.063, blue: 0.063) // #101010

    static let safeZone = Color(red: 0.133, green: 0.545, blue: 0.333) // green — matches the deck's safe-zone pin
    static let resource = Color(red: 0.145, green: 0.388, blue: 0.922) // blue — matches the deck's resource pin

    static let goldGradient = LinearGradient(
        colors: [cuGoldLight, cuGold, cuGoldDark],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static func gradient(for color: Color) -> LinearGradient {
        LinearGradient(colors: [color.opacity(0.85), color], startPoint: .top, endPoint: .bottom)
    }
}

extension View {
    /// Consistent elevated-card treatment: background fill + soft shadow.
    /// Use for anything meant to read as a tappable surface sitting above
    /// the page (banners, rows, buttons) rather than flat inline content.
    func cardStyle(cornerRadius: CGFloat = 16, fill: Color = Color(.secondarySystemBackground)) -> some View {
        self
            .background(fill, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .shadow(color: .black.opacity(0.10), radius: 12, x: 0, y: 6)
    }

    /// A softer shadow for elements already sitting on a tinted background
    /// (e.g. a gradient banner), where a strong shadow would look heavy.
    func subtleShadow() -> some View {
        self.shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 3)
    }
}

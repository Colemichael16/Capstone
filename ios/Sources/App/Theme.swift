import SwiftUI

/// CU Boulder brand colors (official CU Gold / Black), used for app chrome.
/// Alert severity colors stay separate (`AlertSeverity.color`) — those are
/// a cross-client contract with web/src/alerts/contract.js and shouldn't
/// shift for branding reasons.
enum Theme {
    static let cuGold = Color(red: 0.812, green: 0.722, blue: 0.486) // #CFB87C
    static let cuBlack = Color(red: 0.063, green: 0.063, blue: 0.063) // #101010

    static let safeZone = Color(red: 0.133, green: 0.545, blue: 0.333) // green — matches the deck's safe-zone pin
    static let resource = Color(red: 0.145, green: 0.388, blue: 0.922) // blue — matches the deck's resource pin
}

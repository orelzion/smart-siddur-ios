import SwiftUI

/// DesignTokens provides a unified design token system for light and dark themes
/// All colors adapt automatically based on system appearance
@available(iOS 17, *)
struct DesignTokens {
    /// Primary dark gradient background for dark mode
    /// Light mode uses a warm cream background
    static func backgroundPrimary() -> LinearGradient {
        if #available(iOS 18, *) {
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.06, green: 0.09, blue: 0.16),  // #0f172a
                    Color(red: 0.01, green: 0.02, blue: 0.04)   // #020617
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.06, green: 0.09, blue: 0.16),  // #0f172a
                    Color(red: 0.01, green: 0.02, blue: 0.04)   // #020617
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    /// Card background - semi-transparent with glass effect
    static let bgCard = Color(red: 0.11, green: 0.13, blue: 0.20)  // #1c2230 with opacity
    
    /// Border color for cards
    static let borderCard = Color(red: 0.20, green: 0.22, blue: 0.31)  // #343847
    
    /// Primary accent gold color
    static let accentGold = Color(red: 0.85, green: 0.73, blue: 0.27)  // #dab946
    
    /// Secondary accent gold for darker contexts
    static let accentGoldDark = Color(red: 0.72, green: 0.58, blue: 0.12)  // #b8941e
    
    /// Light theme primary color - warm cream
    static let bgCardLight = Color(red: 0.98, green: 0.97, blue: 0.96)  // #faf8f5
    
    /// Light theme border color - subtle gray
    static let borderCardLight = Color(red: 0.90, green: 0.88, blue: 0.84)  // #e5e0d6
    
    /// Light theme secondary text
    static let textSecondaryLight = Color(red: 0.42, green: 0.40, blue: 0.36)  // #6b6659
    
    /// Seasonal badge background - green tint
    static let badgeGreenBackground = Color(red: 0.29, green: 0.86, blue: 0.50)  // #4ade80
    
    /// Semantic text colors
    static let textPrimary = Color.white
    static let textSecondary = Color(red: 0.70, green: 0.72, blue: 0.78)  // #b3b8c7
    
    // MARK: - Adaptive Accessors
    
    /// Returns the appropriate background primary gradient for current appearance
    static func backgroundPrimaryAdaptive() -> LinearGradient {
        return backgroundPrimary()  // Always dark in this design
    }
    
    /// Returns background color based on current appearance
    static func bgCardAdaptive() -> Color {
        @Environment(\.colorScheme) var colorScheme
        return colorScheme == .dark ? bgCard : bgCardLight
    }
    
    /// Returns border color based on current appearance
    static func borderCardAdaptive() -> Color {
        @Environment(\.colorScheme) var colorScheme
        return colorScheme == .dark ? borderCard : borderCardLight
    }
    
    /// Returns accent gold - slightly adjusted for light mode
    static func accentGoldAdaptive() -> Color {
        @Environment(\.colorScheme) var colorScheme
        return colorScheme == .dark ? accentGold : accentGoldDark
    }
    
    /// Returns text color based on current appearance
    static func textAdaptive() -> Color {
        @Environment(\.colorScheme) var colorScheme
        return colorScheme == .dark ? textPrimary : Color.black
    }
    
    /// Returns secondary text color based on current appearance
    static func textSecondaryAdaptive() -> Color {
        @Environment(\.colorScheme) var colorScheme
        return colorScheme == .dark ? textSecondary : textSecondaryLight
    }
}

// MARK: - Color Assets Extension
/// Extension to make design tokens accessible via Color environment
extension ShapeStyle where Self == Color {
    static var themeBgCard: Color {
        Color("BgCard")
    }
    
    static var themeBorderCard: Color {
        Color("BorderCard")
    }
    
    static var themeAccentGold: Color {
        Color("AccentGold")
    }
    
    static var themeTextPrimary: Color {
        Color("TextPrimary")
    }
    
    static var themeTextSecondary: Color {
        Color("TextSecondary")
    }
    
    static var themeBadgeGreen: Color {
        Color("BadgeGreen")
    }
}

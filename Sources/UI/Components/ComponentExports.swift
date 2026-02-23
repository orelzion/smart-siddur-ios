import SwiftUI

// MARK: - Component Library Exports
// All UI components for the Smart Siddur redesign
//
// Usage:
// - GlassCard: .glassCard() modifier for glass morphism styling
// - GoldGradientText: Text with white-to-gold gradient fill
// - PrimaryButton: Gold CTA button with haptic feedback
// - SegmentedPicker: Custom segmented control with gold accent
// - ZmanRow: Prayer time display row with glass card
// - SuggestedCard: Small quick-access card for prayers/blessings
// - SeasonalBadge: Seasonal context badge (green-tinted)
// - HeroCard: Large hero card with countdown timer

/// View modifier for glass card styling
/// Usage: .glassCard() or .glassCard(cornerRadius: 20)
public extension View {
    func glassCard(cornerRadius: CGFloat = 16, borderOpacity: CGFloat = 0.5) -> some View {
        modifier(GlassCard(cornerRadius: cornerRadius, borderOpacity: borderOpacity))
    }
    
    func goldGradient() -> some View {
        foregroundStyle(
            LinearGradient(
                gradient: Gradient(colors: [
                    .white,
                    Color(red: 0.85, green: 0.73, blue: 0.27)  // #dab946 - accentGold
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .bold()
    }
}

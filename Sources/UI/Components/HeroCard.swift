import SwiftUI
import UIKit

/// HeroCard displays a large prayer card with countdown timer and multi-line layout
/// Supports transitional state (both prayer options) and automatic timer updates
/// Includes multi-line content: prayer name, milestone, countdown, context
struct HeroCard: View {
    let prayerName: String
    let hebrewName: String
    let milestoneTitle: String
    let countdown: String
    let halachicContext: String
    let alternativePrayer: String?  // For transitional state (Shkia->Tzet)
    let isTransitional: Bool
    let action: () -> Void
    
    @Environment(\.colorScheme) var colorScheme
    @State private var isPressed = false
    
    var body: some View {
        Button(action: triggerAction) {
            VStack(spacing: 16) {
                // Prayer name and Hebrew - top section
                VStack(spacing: 4) {
                    Text(prayerName)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(Color(red: 0.85, green: 0.73, blue: 0.27))  // accentGold
                    
                    Text(hebrewName)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Color.white)
                }
                
                // Milestone and countdown - center section
                VStack(spacing: 8) {
                    Text(milestoneTitle)
                        .font(.headline)
                        .foregroundStyle(Color(red: 0.70, green: 0.72, blue: 0.78))  // textSecondary
                    
                    HStack(spacing: 8) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color(red: 0.85, green: 0.73, blue: 0.27))  // accentGold
                        
                        Text(countdown)
                            .font(.system(size: 32, weight: .bold, design: .monospaced))
                            .foregroundStyle(Color(red: 0.85, green: 0.73, blue: 0.27))  // accentGold
                    }
                }
                
                // Halachic context - bottom section
                Text(halachicContext)
                    .font(.caption)
                    .foregroundStyle(Color(red: 0.70, green: 0.72, blue: 0.78))  // textSecondary
                    .italic()
                
                // Transitional state - show both options
                if isTransitional, let altPrayer = alternativePrayer {
                    Divider()
                        .opacity(0.3)
                    
                    HStack(spacing: 12) {
                        VStack(alignment: .center, spacing: 4) {
                            Text(prayerName)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.white)
                            
                            Text(hebrewName)
                                .font(.caption2)
                                .foregroundStyle(Color(red: 0.70, green: 0.72, blue: 0.78))
                        }
                        .frame(maxWidth: .infinity)
                        
                        Divider()
                            .opacity(0.3)
                        
                        VStack(alignment: .center, spacing: 4) {
                            Text(altPrayer)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.white)
                            
                            Text("ערבית")
                                .font(.caption2)
                                .foregroundStyle(Color(red: 0.70, green: 0.72, blue: 0.78))
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.top, 8)
                }
            }
            .padding(24)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(red: 0.11, green: 0.13, blue: 0.20))  // #1c2230
                    .opacity(0.4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(red: 0.85, green: 0.73, blue: 0.27),  // accentGold
                                Color(red: 0.72, green: 0.58, blue: 0.12)   // accentGoldDark
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            )
        }
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    isPressed = true
                }
                .onEnded { _ in
                    isPressed = false
                }
        )
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
    }
    
    private func triggerAction() {
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        action()
    }
}

#Preview {
    ZStack {
        LinearGradient(
            gradient: Gradient(colors: [
                Color(red: 0.06, green: 0.09, blue: 0.16),  // #0f172a
                Color(red: 0.01, green: 0.02, blue: 0.04)   // #020617
            ]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
        
        VStack(spacing: 24) {
            HeroCard(
                prayerName: "Shacharit",
                hebrewName: "שחרית",
                milestoneTitle: "Countdown to Netz HaChama",
                countdown: "45:30",
                halachicContext: "Sunrise - earliest preferred Shacharit",
                alternativePrayer: nil,
                isTransitional: false,
                action: { print("Shacharit tapped") }
            )
            
            HeroCard(
                prayerName: "Transitional",
                hebrewName: "בין הערביים",
                milestoneTitle: "Countdown to Tzet HaKochavim",
                countdown: "15:45",
                halachicContext: "Between Mincha and Arvit",
                alternativePrayer: "Arvit",
                isTransitional: true,
                action: { print("Transitional tapped") }
            )
            
            Spacer()
        }
        .padding(16)
    }
}

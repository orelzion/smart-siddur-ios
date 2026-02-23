import SwiftUI

/// ZmanRow displays a prayer time (zman) in a glass card row layout
/// Shows icon, label, time value, and optional highlight state for next upcoming zman
struct ZmanRow: View {
    let icon: String  // SF Symbol name
    let label: String
    let time: String
    let isNextUpcoming: Bool
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(
                    isNextUpcoming
                        ? Color(red: 0.85, green: 0.73, blue: 0.27)  // accentGold
                        : Color(red: 0.70, green: 0.72, blue: 0.78)   // textSecondary
                )
                .frame(width: 32, alignment: .center)
            
            // Label
            Text(label)
                .font(.body)
                .foregroundStyle(Color.white)
            
            Spacer()
            
            // Time value - always gold
            Text(time)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundStyle(Color(red: 0.85, green: 0.73, blue: 0.27))  // accentGold
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .glassCard(cornerRadius: 12)
        .overlay(
            isNextUpcoming
                ? RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        Color(red: 0.85, green: 0.73, blue: 0.27),  // accentGold
                        lineWidth: 2
                    )
                : nil
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(label)
        .accessibilityValue(time)
        .accessibilityHint(isNextUpcoming ? "Next upcoming zman" : "")
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
        
        VStack(spacing: 12) {
            Text("Today's Zmanim")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            ZmanRow(
                icon: "sunrise.fill",
                label: "Netz HaChama",
                time: "6:45 AM",
                isNextUpcoming: true
            )
            
            ZmanRow(
                icon: "clock",
                label: "Sof Zman Kriat Shma",
                time: "9:30 AM",
                isNextUpcoming: false
            )
            
            ZmanRow(
                icon: "sun.max.fill",
                label: "Chatzot HaYom",
                time: "12:00 PM",
                isNextUpcoming: false
            )
            
            ZmanRow(
                icon: "sunset.fill",
                label: "Shkia",
                time: "5:45 PM",
                isNextUpcoming: false
            )
            
            Spacer()
        }
        .padding(16)
    }
}

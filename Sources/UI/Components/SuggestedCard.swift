import SwiftUI

/// SuggestedCard displays a small quick-access glass card with icon and title
/// Includes optional badge overlay support and tap gesture handling
struct SuggestedCard: View {
    let icon: String  // SF Symbol name
    let title: String
    let badge: String?
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack(alignment: .topTrailing) {
                VStack(spacing: 8) {
                    Image(systemName: icon)
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(Color(red: 0.85, green: 0.73, blue: 0.27))  // accentGold
                    
                    Text(title)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                }
                .padding(12)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .glassCard(cornerRadius: 12)
                
                // Badge overlay if present
                if let badge = badge {
                    Text(badge)
                        .font(.caption2)
                        .fontWeight(.bold)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 4)
                        .background(Color(red: 0.85, green: 0.73, blue: 0.27))  // accentGold
                        .foregroundStyle(Color(red: 0.01, green: 0.02, blue: 0.04))  // #020617
                        .clipShape(.capsule)
                        .offset(x: -8, y: 8)
                }
            }
        }
        .frame(height: 120)
         .scaleEffect(0.98)
         .hoverEffect(.lift)
         .accessibilityLabel("\(title) prayer or blessing")
         .accessibilityHint("Double tap to open \(title)")
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
        
        VStack(spacing: 20) {
            Text("Suggested For You")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    SuggestedCard(
                        icon: "fork.knife",
                        title: "Birkat HaMazon",
                        badge: nil,
                        action: { print("Birkat HaMazon tapped") }
                    )
                    
                    SuggestedCard(
                        icon: "drop.fill",
                        title: "Asher Yatzar",
                        badge: nil,
                        action: { print("Asher Yatzar tapped") }
                    )
                }
                
                HStack(spacing: 12) {
                    SuggestedCard(
                        icon: "flame.fill",
                        title: "Chanukah",
                        badge: "4",
                        action: { print("Chanukah tapped") }
                    )
                    
                    SuggestedCard(
                        icon: "star.fill",
                        title: "Tehillim",
                        badge: nil,
                        action: { print("Tehillim tapped") }
                    )
                }
            }
            
            Spacer()
        }
        .padding(16)
    }
}

import SwiftUI

/// SeasonalBadge displays seasonal context information with green-tinted background
/// Used for calendar-specific information like Chanukah nights, Sefirat HaOmer, etc.
struct SeasonalBadge: View {
    let icon: String?  // SF Symbol name
    let text: String
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 8) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color(red: 0.29, green: 0.86, blue: 0.50))  // #4ade80 - badgeGreenBackground
            }
            
            Text(text)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(Color(red: 0.29, green: 0.86, blue: 0.50))  // badgeGreenBackground
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(red: 0.29, green: 0.86, blue: 0.50))  // #4ade80
                .opacity(0.1)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(
                    Color(red: 0.29, green: 0.86, blue: 0.50),  // #4ade80
                    lineWidth: 1.5
                )
                .opacity(0.3)
        )
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
        
        VStack(spacing: 16) {
            Text("Seasonal Badges")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            SeasonalBadge(icon: "flame.fill", text: "Chanukah night 3")
            
            SeasonalBadge(icon: "leaf.fill", text: "Sefirat HaOmer tonight")
            
            SeasonalBadge(icon: "calendar", text: "Birkat Ha'Ilanot available")
            
            SeasonalBadge(icon: nil, text: "Rosh Chodesh")
            
            Spacer()
        }
        .padding(16)
    }
}

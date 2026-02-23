import SwiftUI

/// GoldGradientText applies a white-to-gold gradient fill to text
/// Provides a premium appearance with proper color contrast in light mode
struct GoldGradientText: View {
    let text: String
    var font: Font = .largeTitle
    var lineLimit: Int? = 1
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Text(text)
            .font(font)
            .lineLimit(lineLimit)
            .foregroundStyle(
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

/// Convenience function to apply gold gradient to any text view
extension View {
    /// Apply gold gradient fill to this text view
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
        
        VStack(spacing: 30) {
            GoldGradientText(text: "Shalom", font: .system(size: 48))
            
            Text("Greeting")
                .font(.headline)
                .goldGradient()
            
            HStack {
                Text("Welcome to")
                    .font(.title2)
                    .foregroundStyle(.white)
                
                Text("SmartSiddur")
                    .font(.title2)
                    .goldGradient()
            }
        }
        .padding(24)
    }
}

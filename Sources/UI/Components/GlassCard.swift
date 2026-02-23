import SwiftUI

/// GlassCard view modifier provides a glass morphism card effect with blur, border, and corner radius
/// Adapts automatically for light and dark themes
struct GlassCard: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    
    let cornerRadius: CGFloat
    let borderOpacity: CGFloat
    
    init(cornerRadius: CGFloat = 16, borderOpacity: CGFloat = 0.5) {
        self.cornerRadius = cornerRadius
        self.borderOpacity = borderOpacity
    }
    
    func body(content: Content) -> some View {
        content
            .background(
                Group {
                    if #available(iOS 18, *) {
                        // Liquid Glass effect for iOS 18+
                        Color(red: 0.11, green: 0.13, blue: 0.20)  // #1c2230
                            .opacity(colorScheme == .dark ? 0.4 : 0.8)
                            .glassEffect(.regular)
                    } else {
                        // Material effect for iOS 17
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(Color(red: 0.11, green: 0.13, blue: 0.20))
                            .opacity(colorScheme == .dark ? 0.4 : 0.8)
                            .blur(radius: 8)
                    }
                }
            )
            .clipShape(.rect(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(
                        Color(red: 0.20, green: 0.22, blue: 0.31),  // #343847
                        lineWidth: 1
                    )
                    .opacity(borderOpacity)
            )
    }
}

extension View {
    /// Apply glass card styling to this view
    /// - Parameters:
    ///   - cornerRadius: The corner radius of the card (default: 16)
    ///   - borderOpacity: The opacity of the border stroke (default: 0.5)
    func glassCard(cornerRadius: CGFloat = 16, borderOpacity: CGFloat = 0.5) -> some View {
        modifier(GlassCard(cornerRadius: cornerRadius, borderOpacity: borderOpacity))
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
            VStack(spacing: 12) {
                Text("Glass Card Example")
                    .font(.headline)
                    .foregroundStyle(.white)
                
                Text("This is a glass morphism card with blur effect and subtle border")
                    .font(.body)
                    .foregroundStyle(Color(red: 0.70, green: 0.72, blue: 0.78))
            }
            .padding(16)
            .glassCard()
            
            VStack(spacing: 12) {
                Text("Another Card")
                    .font(.headline)
                    .foregroundStyle(.white)
                
                Text("With custom corner radius")
                    .font(.body)
                    .foregroundStyle(Color(red: 0.70, green: 0.72, blue: 0.78))
            }
            .padding(16)
            .glassCard(cornerRadius: 24)
        }
        .padding(16)
    }
}

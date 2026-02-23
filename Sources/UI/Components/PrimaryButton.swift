import SwiftUI
import UIKit

/// PrimaryButton is a gold-styled call-to-action button with haptic feedback
/// Supports disabled and pressed states with smooth animations
struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var isDisabled: Bool = false
    var isLoading: Bool = false
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: triggerAction) {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .tint(Color(red: 0.01, green: 0.02, blue: 0.04))  // #020617
                }
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .padding(.horizontal, 20)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.85, green: 0.73, blue: 0.27),  // #dab946 - accentGold
                        Color(red: 0.72, green: 0.58, blue: 0.12)   // #b8941e - accentGoldDark
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .foregroundStyle(Color(red: 0.01, green: 0.02, blue: 0.04))  // #020617
            .clipShape(.rect(cornerRadius: 12))
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .opacity(isDisabled ? 0.6 : 1.0)
        }
        .disabled(isDisabled || isLoading)
        .pressActionModifier(isPressed: $isPressed)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
    }
    
    private func triggerAction() {
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        // Trigger action
        action()
    }
}

/// Helper modifier to track button press state
private struct PressActionModifier: ViewModifier {
    @Binding var isPressed: Bool
    
    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in
                        isPressed = true
                    }
                    .onEnded { _ in
                        isPressed = false
                    }
            )
    }
}

extension View {
    fileprivate func pressActionModifier(isPressed: Binding<Bool>) -> some View {
        modifier(PressActionModifier(isPressed: isPressed))
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
            PrimaryButton(title: "Primary Action", action: {
                print("Button tapped!")
            })
            
            PrimaryButton(title: "Disabled Button", action: {
                print("Disabled button tapped!")
            }, isDisabled: true)
            
            PrimaryButton(title: "Loading State", action: {
                print("Loading!")
            }, isLoading: true)
            
            Spacer()
        }
        .padding(20)
    }
}

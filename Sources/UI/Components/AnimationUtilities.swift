import SwiftUI

/// Animation utilities for consistent, accessible animations throughout the app
/// Respects user's Reduce Motion accessibility preference
struct AnimationUtilities {
    /// Spring animation for interactive elements (buttons, cards)
    /// Falls back to linear animation when Reduce Motion is enabled
    static func spring(
        response: Double = 0.3,
        dampingFraction: Double = 0.6,
        reduceMotionFallback: Animation = .linear(duration: 0.2)
    ) -> Animation {
        @Environment(\.accessibilityReduceMotion) var reduceMotion
        return reduceMotion ? reduceMotionFallback : .spring(response: response, dampingFraction: dampingFraction)
    }
    
    /// Fade animation for transitions
    /// Respects Reduce Motion setting
    static func fadeTransition(
        duration: Double = 0.2,
        reduceMotionFallback: Animation = .linear(duration: 0.05)
    ) -> Animation {
        @Environment(\.accessibilityReduceMotion) var reduceMotion
        return reduceMotion ? reduceMotionFallback : .easeInOut(duration: duration)
    }
}

/// Extension to make animations more accessible
extension View {
    /// Apply spring animation with Reduce Motion support
    /// - Parameters:
    ///   - response: Duration of spring response (default: 0.3)
    ///   - dampingFraction: Damping for spring (default: 0.6)
    func springAnimation(
        response: Double = 0.3,
        dampingFraction: Double = 0.6,
        value: some Equatable
    ) -> some View {
        @Environment(\.accessibilityReduceMotion) var reduceMotion
        
        let animation: Animation = reduceMotion
            ? .linear(duration: 0.1)
            : .spring(response: response, dampingFraction: dampingFraction)
        
        return self.animation(animation, value: value)
    }
    
    /// Apply fade animation with Reduce Motion support
    func fadeAnimation(
        duration: Double = 0.2,
        value: some Equatable
    ) -> some View {
        @Environment(\.accessibilityReduceMotion) var reduceMotion
        
        let animation: Animation = reduceMotion
            ? .linear(duration: 0.05)
            : .easeInOut(duration: duration)
        
        return self.animation(animation, value: value)
    }
}

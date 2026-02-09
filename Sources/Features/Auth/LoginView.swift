import SwiftUI

/// Placeholder login view. Task 2 will implement full auth flows.
struct LoginView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "book.fill")
                .font(.system(size: 60))
                .foregroundStyle(.blue)
            Text("SmartSiddur")
                .font(.largeTitle.bold())
            Text("Login screen placeholder")
                .foregroundStyle(.secondary)
        }
    }
}

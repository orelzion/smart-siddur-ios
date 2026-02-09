import SwiftUI

@main
struct SmartSiddurApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    @State private var container = DependencyContainer()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(container)
        }
    }
}

/// Placeholder root view. Phase 2 (02-01) will replace with auth state router.
struct ContentView: View {
    @Environment(DependencyContainer.self) private var container

    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "book.fill")
                .font(.system(size: 60))
                .foregroundStyle(.blue)
            Text("SmartSiddur")
                .font(.largeTitle.bold())
            Text("Project initialized. Ready for Phase 2.")
                .foregroundStyle(.secondary)
        }
    }
}

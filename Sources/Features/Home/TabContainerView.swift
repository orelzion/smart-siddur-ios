import SwiftUI

/// Post-auth container with tab navigation.
/// Shows 3 tabs: Zmanim, Calendar, Settings.
struct TabContainerView: View {
    var body: some View {
        TabView {
            // Tab 1: Zmanim (placeholder)
            NavigationStack {
                VStack(spacing: 16) {
                    Image(systemName: "sun.horizon")
                        .font(.system(size: 48))
                        .foregroundStyle(.orange)
                    Text("Zmanim")
                        .font(.title2)
                    Text("Coming soon")
                        .foregroundStyle(.secondary)
                }
                .navigationTitle("Zmanim")
            }
            .tabItem {
                Label("Zmanim", systemImage: "clock")
            }

            // Tab 2: Calendar (placeholder)
            NavigationStack {
                VStack(spacing: 16) {
                    Image(systemName: "calendar")
                        .font(.system(size: 48))
                        .foregroundStyle(.blue)
                    Text("Calendar")
                        .font(.title2)
                    Text("Coming soon")
                        .foregroundStyle(.secondary)
                }
                .navigationTitle("Calendar")
            }
            .tabItem {
                Label("Calendar", systemImage: "calendar")
            }

            // Tab 3: Settings (full settings screen)
            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape")
            }
        }
    }
}

import SwiftUI

/// Post-auth container with tab navigation.
/// Shows 3 tabs: Zmanim, Calendar, Settings.
/// On first launch (no saved location), presents LocationPickerView with GPS auto-detect.
struct TabContainerView: View {
    @Environment(DependencyContainer.self) private var container
    @State private var showLocationSetup = false
    @State private var hasCheckedLocation = false

    var body: some View {
        TabView {
            // Tab 1: Zmanim
            NavigationStack {
                ZmanimView()
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
        .sheet(isPresented: $showLocationSetup) {
            NavigationStack {
                LocationPickerView()
                    .navigationTitle("Set Your Location")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Skip") {
                                showLocationSetup = false
                            }
                        }
                    }
            }
        }
        .task {
            guard !hasCheckedLocation else { return }
            hasCheckedLocation = true
            // Check if user has a saved location; if not, prompt for location setup
            do {
                let existing = try await container.locationRepository.getSelectedLocation()
                if existing == nil {
                    showLocationSetup = true
                } else {
                    container.selectedLocationName = existing?.displayName
                }
            } catch {
                // If check fails (e.g., not authenticated yet), don't show prompt
            }
        }
    }
}

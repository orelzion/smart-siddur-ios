import SwiftUI

/// Post-auth container with tab navigation.
/// Shows 3 tabs:
///   1. Home (NewHomeView) - Next prayer countdown and prayer suggestions
///   2. Calendar/Zmanim (UnifiedCalendarView) - Month/day calendar with special times
///   3. Settings - User preferences and location
///
/// On first launch (no saved location), presents LocationPickerView with GPS auto-detect.
/// Features:
///   - Glass background appearance on tab bar (dark gradient background)
///   - Gold accent tint color (#D9BA1B)
///   - Spring/fade transitions between tabs
///   - Haptic feedback on tab switch
struct TabContainerView: View {
    @Environment(DependencyContainer.self) private var container
    @State private var showLocationSetup = false
    @State private var hasCheckedLocation = false
    @State private var previousTab: Int = 0

    var body: some View {
        @Bindable var container = container
        
        ZStack {
            // Glass background for entire tab container
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.06, green: 0.09, blue: 0.16),  // #0f172a
                    Color(red: 0.01, green: 0.02, blue: 0.04)   // #020617
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            TabView(selection: $container.selectedTab) {
                // Tab 1: Home
                NavigationStack {
                    NewHomeView(viewModel: HomeViewModel(dependencyContainer: container))
                }
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)

                // Tab 2: Calendar/Zmanim
                NavigationStack {
                    UnifiedCalendarView()
                }
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }
                .tag(1)

                // Tab 3: Settings
                NavigationStack {
                    SettingsView()
                }
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(2)
            }
            .tabViewStyle(.automatic)
            .tint(Color(red: 0.85, green: 0.73, blue: 0.27))  // Gold accent
            .onChange(of: container.selectedTab) { oldValue, newValue in
                handleTabChange(from: oldValue, to: newValue)
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
    
    // MARK: - Tab Change Handler
    
    /// Handle tab changes with haptic feedback
    private func handleTabChange(from oldValue: Int, to newValue: Int) {
        // Trigger haptic feedback on tab switch
        let impactFeedback = UIImpactFeedbackGenerator(style: .light)
        impactFeedback.impactOccurred()
        
        previousTab = oldValue
    }
}

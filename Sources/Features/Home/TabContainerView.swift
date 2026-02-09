import SwiftUI

/// Post-auth container with tab navigation.
/// Task 2 will add sign-out and user info.
struct TabContainerView: View {
    var body: some View {
        TabView {
            Text("Zmanim")
                .tabItem {
                    Label("Zmanim", systemImage: "clock")
                }

            Text("Calendar")
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }

            Text("Settings")
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
    }
}

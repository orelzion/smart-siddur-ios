import SwiftUI
import GoogleSignIn
import SwiftData

@main
struct SmartSiddurApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    @State private var container = DependencyContainer()
    @State private var isAuthenticated = false
    @State private var isCheckingSession = true
    
    var body: some Scene {
        WindowGroup {
            Group {
                if isCheckingSession {
                    ProgressView("Loading...")
                } else if isAuthenticated {
                    TabContainerView()
                } else {
                    OnboardingView()
                }
            }
            .environment(container)
            .modelContainer(for: [CachedPrayer.self]) { result in
                // Configure SwiftData model container with migration handling
                switch result {
                case .success(let container):
                    DependencyContainer.modelContainer = container
                case .failure(let error):
                    print("SwiftData initialization failed: \(error.localizedDescription)")
                }
            }
            .task {
                for await (event, session) in container.supabase.auth.authStateChanges {
                    isCheckingSession = false
                    switch event {
                    case .initialSession, .signedIn, .tokenRefreshed:
                        // Check session validity: ensure session exists and is not expired
                        isAuthenticated = session != nil && !(session?.isExpired ?? true)
                    case .signedOut:
                        isAuthenticated = false
                    default:
                        break
                    }
                }
            }
            .task {
                // Perform background cache refresh on app launch
                if let cacheService = container.prayerCacheService {
                    try? await cacheService.performBackgroundRefreshIfNeeded()
                }
                // Schedule background refresh for future app launches
                PrayerBackgroundTaskManager.shared.scheduleAppRefresh()
            }
            .onOpenURL { url in
                GIDSignIn.sharedInstance.handle(url)
            }
        }
    }
}

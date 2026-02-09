import Foundation
import Observation
import Supabase
import SwiftData

@MainActor
@Observable
final class DependencyContainer {
    let supabase: SupabaseClient
    let authRepository: AuthRepository
    let settingsRepository: SettingsRepository
    let localSettings: LocalSettings
    let locationRepository: LocationRepository
    let zmanimService: ZmanimService
    let jewishCalendarService: JewishCalendarService
    let prayerService: PrayerService
    let prayerCacheService: PrayerCacheService?

    /// SwiftData model container for caching
    static var modelContainer: ModelContainer?

    /// Currently selected location name, updated by LocationViewModel.
    var selectedLocationName: String?

    /// When set, the Zmanim tab should load zmanim for this date.
    /// Set by CalendarView's "View Full Zmanim" action, consumed by ZmanimView.
    var zmanimDateOverride: Date?

    /// Currently selected tab index (0=Zmanim, 1=Calendar, 2=Prayers, 3=Settings).
    var selectedTab: Int = 0
    
    /// Shared instance for easy access
    static let shared = DependencyContainer()

    init() {
        self.supabase = SupabaseConfig.client
        self.authRepository = AuthRepository(supabase: SupabaseConfig.client)
        self.settingsRepository = SettingsRepository(supabase: SupabaseConfig.client)
        self.localSettings = LocalSettings.shared
        self.locationRepository = LocationRepository(supabase: SupabaseConfig.client)
        self.zmanimService = ZmanimService()
        self.jewishCalendarService = JewishCalendarService()
        self.prayerService = PrayerService(supabase: SupabaseConfig.client)
        
        // Initialize cache service if SwiftData is available
        if let modelContext = DependencyContainer.createModelContext() {
            self.prayerCacheService = PrayerCacheService(
                modelContext: modelContext,
                prayerService: prayerService,
                localSettings: localSettings
            )
        } else {
            self.prayerCacheService = nil
        }
    }
    
    /// Creates a SwiftData model context for the cache
    static func createModelContext() -> ModelContext? {
        guard let container = modelContainer else {
            return nil
        }
        return container.mainContext
    }
}

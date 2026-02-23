import Foundation
import Observation
import Supabase
import SwiftData
import OSLog

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
    let nextPrayerService: NextPrayerService

    /// SwiftData model container for caching
    static var modelContainer: ModelContainer?

    /// Currently selected location name, updated by LocationViewModel.
    var selectedLocationName: String?

    /// When set, the Zmanim tab should load zmanim for this date.
    /// Set by CalendarView's "View Full Zmanim" action, consumed by ZmanimView.
    var zmanimDateOverride: Date?

    /// Currently selected tab index (0=Zmanim, 1=Calendar, 2=Prayers, 3=Settings).
    var selectedTab: Int = 0
    
    /// Cached synced user settings (refreshed on demand)
    private var _cachedSyncedSettings: SyncedUserSettings?
    
    /// Shared instance for easy access
    static let shared = DependencyContainer()

    private let logger = Logger(subsystem: "com.karriapps.smartsiddur", category: "DependencyContainer")

    init() {
        let supabaseClient = SupabaseConfig.client
        let settingsRepo = SettingsRepository(supabase: supabaseClient)
        let localSet = LocalSettings.shared
        let locRepo = LocationRepository(supabase: supabaseClient)
        let zmanim = ZmanimService()
        let jewishCal = JewishCalendarService()
        let prayerSvc = PrayerService(supabase: supabaseClient)
        let nextPrayer = NextPrayerService(zmanimService: zmanim, jewishCalendarService: jewishCal)
        
        self.supabase = supabaseClient
        self.authRepository = AuthRepository(supabase: supabaseClient)
        self.settingsRepository = settingsRepo
        self.localSettings = localSet
        self.locationRepository = locRepo
        self.zmanimService = zmanim
        self.jewishCalendarService = jewishCal
        self.prayerService = prayerSvc
        self.nextPrayerService = nextPrayer
        
        // Initialize cache service if SwiftData is available
        // Use a helper to avoid capturing self before full initialization
        let settingsRepoCopy = settingsRepo
        let getSyncedSettingsHelper: () async -> SyncedUserSettings = {
            do {
                return try await settingsRepoCopy.fetchSyncedSettings()
            } catch {
                return .defaults
            }
        }
        
        if let modelContext = DependencyContainer.createModelContext() {
            self.prayerCacheService = PrayerCacheService(
                modelContext: modelContext,
                prayerService: prayerSvc,
                localSettings: localSet,
                locationRepository: locRepo,
                getSyncedSettings: getSyncedSettingsHelper
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
    
    /// Invalidates the prayer cache when settings change
    func invalidatePrayerCache() async {
        guard let cacheService = prayerCacheService else { return }
        try? await cacheService.invalidateCache()
    }
    
    /// Gets synced settings with fallback to defaults on error
    func getSyncedSettings() async -> SyncedUserSettings {
        if let cached = _cachedSyncedSettings {
            return cached
        }
        
        do {
            let settings = try await settingsRepository.fetchSyncedSettings()
            _cachedSyncedSettings = settings
            return settings
        } catch {
            logger.error("Failed to fetch synced settings: \(error.localizedDescription), using defaults")
            return .defaults
        }
    }
    
    /// Clears cached synced settings (call after settings update)
    func clearSyncedSettingsCache() {
        _cachedSyncedSettings = nil
    }
}

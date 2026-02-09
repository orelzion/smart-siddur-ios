import Foundation
import Observation
import Supabase

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

    /// Currently selected location name, updated by LocationViewModel.
    var selectedLocationName: String?

    /// When set, the Zmanim tab should load zmanim for this date.
    /// Set by CalendarView's "View Full Zmanim" action, consumed by ZmanimView.
    var zmanimDateOverride: Date?

    /// Currently selected tab index (0=Zmanim, 1=Calendar, 2=Settings).
    var selectedTab: Int = 0

    init() {
        self.supabase = SupabaseConfig.client
        self.authRepository = AuthRepository(supabase: SupabaseConfig.client)
        self.settingsRepository = SettingsRepository(supabase: SupabaseConfig.client)
        self.localSettings = LocalSettings.shared
        self.locationRepository = LocationRepository(supabase: SupabaseConfig.client)
        self.zmanimService = ZmanimService()
        self.jewishCalendarService = JewishCalendarService()
    }
}

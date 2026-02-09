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

import Foundation
import Observation

/// View model for the Settings screen.
/// Manages both synced settings (Supabase) and local settings (UserDefaults).
/// Synced settings use optimistic updates: apply locally first, then push to server.
@MainActor
@Observable
final class SettingsViewModel {
    // MARK: - Published State

    var syncedSettings: SyncedUserSettings = .defaults
    var isLoading = false
    var error: String?
    var isSaving = false

    // MARK: - Dependencies

    let localSettings: LocalSettings
    private let settingsRepository: SettingsRepositoryProtocol

    // MARK: - Init

    init(settingsRepository: SettingsRepositoryProtocol, localSettings: LocalSettings) {
        self.settingsRepository = settingsRepository
        self.localSettings = localSettings
    }

    // MARK: - Load

    func loadSettings() {
        guard !isLoading else { return }
        isLoading = true
        error = nil
        Task {
            do {
                self.syncedSettings = try await settingsRepository.fetchSyncedSettings()
            } catch {
                self.error = error.localizedDescription
            }
            self.isLoading = false
        }
    }

    // MARK: - Synced Setting Updates (Optimistic)

    /// Update nusach with optimistic local update, then push to Supabase.
    func updateNusach(_ nusach: Nusach) {
        let previous = syncedSettings.nusach
        syncedSettings.nusach = nusach
        pushSingleSetting("nusach", value: nusach.rawValue, rollback: { self.syncedSettings.nusach = previous })
    }

    func updateIsWoman(_ value: Bool) {
        let previous = syncedSettings.isWoman
        syncedSettings.isWoman = value
        pushSingleSetting("is_woman", value: value, rollback: { self.syncedSettings.isWoman = previous })
    }

    func updateLanguage(_ language: AppLanguage) {
        let previous = syncedSettings.language
        syncedSettings.language = language
        pushSingleSetting("language", value: language.rawValue, rollback: { self.syncedSettings.language = previous })
    }

    func updateIsInIsrael(_ value: Bool) {
        let previous = syncedSettings.isInIsrael
        syncedSettings.isInIsrael = value
        pushSingleSetting("is_in_israel", value: value, rollback: { self.syncedSettings.isInIsrael = previous })
    }

    func updateIsMizrochnik(_ value: Bool) {
        let previous = syncedSettings.isMizrochnik
        syncedSettings.isMizrochnik = value
        pushSingleSetting("is_mizrochnik", value: value, rollback: { self.syncedSettings.isMizrochnik = previous })
    }

    func updateMukafMode(_ mode: MukafMode) {
        let previous = syncedSettings.mukafMode
        syncedSettings.mukafMode = mode
        pushSingleSetting("mukaf_mode", value: mode.rawValue, rollback: { self.syncedSettings.mukafMode = previous })
    }

    func updateDateChangeRule(_ rule: DateChangeRule) {
        let previous = syncedSettings.dateChangeRule
        syncedSettings.dateChangeRule = rule
        pushSingleSetting("date_change_rule", value: rule.rawValue, rollback: { self.syncedSettings.dateChangeRule = previous })
    }

    func updatePasuk(_ pasuk: String) {
        let previous = syncedSettings.pasuk
        syncedSettings.pasuk = pasuk
        pushSingleSetting("pasuk", value: pasuk, rollback: { self.syncedSettings.pasuk = previous })
    }

    func updateSickName(_ name: String) {
        let previous = syncedSettings.sickName
        syncedSettings.sickName = name
        pushSingleSetting("sick_name", value: name, rollback: { self.syncedSettings.sickName = previous })
    }

    func updateTalPreference(_ value: Bool) {
        let previous = syncedSettings.talPreference
        syncedSettings.talPreference = value
        pushSingleSetting("tal_preference", value: value, rollback: { self.syncedSettings.talPreference = previous })
    }

    func updateShabbatCandleMinutes(_ value: Int) {
        let previous = syncedSettings.shabbatCandleMinutes
        syncedSettings.shabbatCandleMinutes = value
        pushSingleSetting("shabbat_candle_minutes", value: value, rollback: { self.syncedSettings.shabbatCandleMinutes = previous })
    }

    func updateShabbatEndMinutes(_ value: Int) {
        let previous = syncedSettings.shabbatEndMinutes
        syncedSettings.shabbatEndMinutes = value
        pushSingleSetting("shabbat_end_minutes", value: value, rollback: { self.syncedSettings.shabbatEndMinutes = previous })
    }

    func updateDawnOpinion(_ opinion: DawnOpinion) {
        let previous = syncedSettings.dawnOpinion
        syncedSettings.dawnOpinion = opinion
        pushSingleSetting("dawn_opinion", value: opinion.rawValue, rollback: { self.syncedSettings.dawnOpinion = previous })
    }

    func updateSunriseOpinion(_ opinion: SunriseOpinion) {
        let previous = syncedSettings.sunriseOpinion
        syncedSettings.sunriseOpinion = opinion
        pushSingleSetting("sunrise_opinion", value: opinion.rawValue, rollback: { self.syncedSettings.sunriseOpinion = previous })
    }

    func updateZmanOpinion(_ opinion: ZmanOpinion) {
        let previous = syncedSettings.zmanOpinion
        syncedSettings.zmanOpinion = opinion
        pushSingleSetting("zman_opinion", value: opinion.rawValue, rollback: { self.syncedSettings.zmanOpinion = previous })
    }

    func updateDuskOpinion(_ opinion: DuskOpinion) {
        let previous = syncedSettings.duskOpinion
        syncedSettings.duskOpinion = opinion
        pushSingleSetting("dusk_opinion", value: opinion.rawValue, rollback: { self.syncedSettings.duskOpinion = previous })
    }

    // MARK: - Private Helpers

    /// Push a single setting update to Supabase, with rollback on failure.
    private func pushSingleSetting(
        _ column: String,
        value: some Encodable & Sendable,
        rollback: @escaping @MainActor () -> Void
    ) {
        isSaving = true
        Task {
            do {
                try await settingsRepository.updateSingleSetting(column, value: value)
            } catch {
                rollback()
                self.error = "Failed to save: \(error.localizedDescription)"
            }
            self.isSaving = false
        }
    }
}

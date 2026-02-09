import Foundation
import Observation

/// ViewModel for the Zmanim display screen.
/// Calculates halachic times using ZmanimService with user's opinions and location.
@MainActor
@Observable
final class ZmanimViewModel {
    // MARK: - Dependencies

    private let zmanimService: ZmanimService
    private let settingsRepository: SettingsRepositoryProtocol
    private let locationRepository: LocationRepositoryProtocol
    private let localSettings: LocalSettings

    // MARK: - State

    var zmanimList: [ZmanTime] = []
    var shabbatTimes: [ZmanTime] = []
    var showAllTimes: Bool = false
    var selectedDate: Date = Date()
    var isLoading: Bool = false
    var errorMessage: String?
    var locationName: String = ""

    /// The ID of the next upcoming zman for highlighting.
    var nextZmanId: String?

    /// Jewish calendar info for today's header.
    var hebrewDateString: String = ""

    /// Whether the current date is Friday or Shabbat (to show Shabbat section).
    var hasShabbatTimes: Bool {
        !shabbatTimes.isEmpty
    }

    /// Filtered list based on showAllTimes toggle, sorted chronologically by time.
    var displayedZmanim: [ZmanTime] {
        let filtered = showAllTimes ? zmanimList : zmanimList.filter(\.isEssential)
        return filtered.sorted { a, b in
            let timeA = a.time ?? .distantFuture
            let timeB = b.time ?? .distantFuture
            return timeA < timeB
        }
    }

    // MARK: - Init

    init(
        zmanimService: ZmanimService,
        settingsRepository: SettingsRepositoryProtocol,
        locationRepository: LocationRepositoryProtocol,
        localSettings: LocalSettings
    ) {
        self.zmanimService = zmanimService
        self.settingsRepository = settingsRepository
        self.locationRepository = locationRepository
        self.localSettings = localSettings
    }

    // MARK: - Public

    /// Load settings, location, and calculate zmanim.
    func loadZmanim() async {
        isLoading = true
        errorMessage = nil

        do {
            // Fetch user location
            guard let location = try await locationRepository.getSelectedLocation() else {
                errorMessage = "No location set. Please set your location in Settings."
                isLoading = false
                return
            }
            locationName = location.displayName

            // Fetch synced settings for opinions
            let settings: SyncedUserSettings
            do {
                settings = try await settingsRepository.fetchSyncedSettings()
            } catch {
                // Use defaults if settings can't be fetched
                settings = .defaults
            }

            let opinions = ZmanimOpinions(
                dawnOpinion: settings.dawnOpinion,
                sunriseOpinion: settings.sunriseOpinion,
                zmanOpinion: settings.zmanOpinion,
                duskOpinion: settings.duskOpinion,
                shabbatCandleMinutes: settings.shabbatCandleMinutes,
                shabbatEndMinutes: settings.shabbatEndMinutes
            )

            // Calculate zmanim
            var allZmanim = zmanimService.calculateZmanim(
                date: selectedDate,
                location: location,
                opinions: opinions
            )

            // Mark next upcoming
            markNextUpcoming(&allZmanim)
            zmanimList = allZmanim

            // Calculate Shabbat times
            shabbatTimes = zmanimService.shabbatTimes(
                date: selectedDate,
                location: location,
                opinions: opinions
            )

            // Hebrew date for header
            updateHebrewDate()

        } catch {
            errorMessage = "Failed to calculate zmanim: \(error.localizedDescription)"
        }

        isLoading = false
    }

    /// Recalculate with current settings (pull-to-refresh).
    func refresh() async {
        await loadZmanim()
    }

    // MARK: - Private

    /// Find the next upcoming zman (first zman with time > now) and mark it.
    private func markNextUpcoming(_ zmanim: inout [ZmanTime]) {
        let now = Date()
        nextZmanId = nil

        for i in zmanim.indices {
            zmanim[i].isNextUpcoming = false
        }

        // Sort by time, find first future zman
        let sortedIndices = zmanim.indices.sorted { a, b in
            let timeA = zmanim[a].time ?? .distantFuture
            let timeB = zmanim[b].time ?? .distantFuture
            return timeA < timeB
        }

        for idx in sortedIndices {
            if let time = zmanim[idx].time, time > now {
                zmanim[idx].isNextUpcoming = true
                nextZmanId = zmanim[idx].id
                break
            }
        }
    }

    /// Update Hebrew date string for display.
    private func updateHebrewDate() {
        let jewishCalendar = JewishCalendarService()
        let day = jewishCalendar.getJewishDay(for: selectedDate, isInIsrael: false)
        hebrewDateString = day.hebrewDateString
    }
}

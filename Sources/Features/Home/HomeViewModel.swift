import Foundation
import Observation
import SwiftUI
import OSLog

@MainActor
@Observable
final class HomeViewModel {
    private let nextPrayerService: NextPrayerService
    private let prayerVisibilityService: PrayerVisibilityService
    private let jewishCalendarService: JewishCalendarService
    private let authViewModel: AuthViewModel
    private let dependencyContainer: DependencyContainer
    private let logger = Logger(subsystem: "com.karriapps.smartsiddur", category: "HomeViewModel")

    var greetingText = "Shalom"
    var dateText = ""
    var nextPrayerState: NextPrayerState = .empty
    var suggestedItems: [SuggestedItem] = []
    var seasonalBadgeText: String?
    var filteredPrayers: [PrayerType] = [.shacharit, .mincha, .arvit, .mazon, .alMita, .blessings]
    var highlightedPrayer: PrayerType?
    var isLoading = false

    private var currentJewishDay: JewishDay?
    private var selectedLocation: UserLocation?
    private var userOpinions: ZmanimOpinions = .defaults
    private var isInIsrael = false
    private var nusach: Nusach = .edot
    private var refreshTimer: Timer?

    init(
        dependencyContainer: DependencyContainer,
        nextPrayerService: NextPrayerService? = nil,
        prayerVisibilityService: PrayerVisibilityService? = nil,
        jewishCalendarService: JewishCalendarService? = nil,
        authViewModel: AuthViewModel? = nil
    ) {
        self.dependencyContainer = dependencyContainer
        self.nextPrayerService = nextPrayerService ?? dependencyContainer.nextPrayerService
        self.prayerVisibilityService = prayerVisibilityService ?? PrayerVisibilityService()
        self.jewishCalendarService = jewishCalendarService ?? dependencyContainer.jewishCalendarService
        self.authViewModel = authViewModel ?? AuthViewModel(authRepository: dependencyContainer.authRepository)
        updateGreeting()
    }

    func start() {
        stop()
        Task { await refreshData() }
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            Task { @MainActor in
                await self?.refreshData(lightweight: true)
            }
        }
    }

    func stop() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }

    func onSceneDidBecomeActive() {
        Task { await refreshData() }
    }

    private func refreshData(lightweight: Bool = false) async {
        if !lightweight {
            isLoading = true
        }

        updateGreeting()
        await loadUserContextIfNeeded()
        let now = Date()
        updateJewishDayAndDates(for: now)
        updatePrayerData(for: now)

        isLoading = false
    }

    private func updateGreeting() {
        if let displayName = authViewModel.displayName, !displayName.isEmpty {
            greetingText = "Shalom, \(displayName)"
        } else {
            greetingText = "Shalom"
        }
    }

    private func loadUserContextIfNeeded() async {
        if selectedLocation == nil {
            do {
                selectedLocation = try await dependencyContainer.locationRepository.getSelectedLocation()
            } catch {
                logger.error("Failed to load selected location: \(error.localizedDescription)")
            }
        }

        let settings = await dependencyContainer.getSyncedSettings()
        isInIsrael = settings.isInIsrael
        nusach = settings.nusach
        userOpinions = ZmanimOpinions(
            dawnOpinion: settings.dawnOpinion,
            sunriseOpinion: settings.sunriseOpinion,
            zmanOpinion: settings.zmanOpinion,
            duskOpinion: settings.duskOpinion,
            shabbatCandleMinutes: settings.shabbatCandleMinutes,
            shabbatEndMinutes: settings.shabbatEndMinutes
        )
    }

    private func updateJewishDayAndDates(for date: Date) {
        let jewishDay = jewishCalendarService.getJewishDay(for: date, isInIsrael: isInIsrael)
        currentJewishDay = jewishDay

        let gregorianText = LocaleFormatters.dayMonthYear(date)
        dateText = "\(jewishDay.hebrewDateString) / \(gregorianText)"
    }

    private func updatePrayerData(for date: Date) {
        seasonalBadgeText = jewishCalendarService.seasonalBadge(for: date)

        if let location = selectedLocation {
            nextPrayerState = nextPrayerService.calculateCurrentState(
                for: date,
                location: location,
                opinions: userOpinions,
                isInIsrael: isInIsrael
            )
        } else {
            nextPrayerState = .empty
        }

        suggestedItems = prayerVisibilityService.suggestedItems(for: date)
        removeDuplicateArvitSuggestionIfCoveredByCTA()
        addNightSuggestionsIfApplicable()

        filteredPrayers = removeSuggestedFromGrid(buildPrayerGrid(for: date))
        highlightedPrayer = nextPrayerState.prayer ?? (nextPrayerState.isTransitional ? .mincha : nextPrayerState.alternativePrayer)
    }

    private func removeDuplicateArvitSuggestionIfCoveredByCTA() {
        let isArvitInCTA = nextPrayerState.prayer == .arvit || nextPrayerState.isTransitional
        guard isArvitInCTA else { return }
        suggestedItems.removeAll { $0.prayerType == .arvit }
    }

    private func addNightSuggestionsIfApplicable() {
        let isNightWindow = nextPrayerState.prayer == .arvit
        guard isNightWindow else { return }

        if !suggestedItems.contains(where: { $0.prayerType == .alMita }) {
            suggestedItems.append(
                SuggestedItem(
                    icon: "bed.double.fill",
                    title: "Kriat Shema Al HaMita",
                    hebrewTitle: "קריאת שמע על המיטה",
                    prayerType: .alMita,
                    description: "Before sleep"
                )
            )
        }

        if
            let jewishDay = currentJewishDay,
            (3...15).contains(jewishDay.hebrewDay),
            !suggestedItems.contains(where: { $0.prayerType == .levana })
        {
            suggestedItems.append(
                SuggestedItem(
                    icon: "moon.circle.fill",
                    title: "Birkat HaLevana",
                    hebrewTitle: "ברכת הלבנה",
                    prayerType: .levana,
                    description: "After 3 days from molad until the 15th"
                )
            )
        }
    }

    private func buildPrayerGrid(for date: Date) -> [PrayerType] {
        let alwaysShown: [PrayerType] = [.shacharit, .mincha, .arvit, .mazon, .alMita, .blessings]
        guard let jewishDay = currentJewishDay else { return alwaysShown }

        let context = PrayerVisibilityContext(
            jewishDay: jewishDay,
            nusach: nusach,
            isMotzaeiShabbat: jewishDay.isShabbat && isAfterTzet(for: date),
            isLevanaAvailable: jewishDay.hebrewDay >= 3 && jewishDay.hebrewDay <= 15,
            isAfterPlagOnErevChanukah: false
        )

        var visible = Set(alwaysShown)
        visible.formUnion(prayerVisibilityService.visiblePrayers(in: context))

        // Show Musaf only for Rosh Chodesh
        if jewishDay.isRoshChodesh || jewishDay.isCholHamoed {
            visible.insert(.musaf)
        }

        let order: [PrayerType] = [
            .shacharit, .mincha, .arvit, .musaf, .torahReading, .omer, .hanuka, .slihot,
            .havdala, .lagBaomer, .ilanot, .levana, .kinot, .nedarim, .ushpizin, .mazon,
            .asherYatzar, .alMita, .blessings
        ]

        return order.filter { visible.contains($0) }
    }

    private func removeSuggestedFromGrid(_ prayers: [PrayerType]) -> [PrayerType] {
        let suggestedTypes = Set(suggestedItems.map(\.prayerType))
        return prayers.filter { !suggestedTypes.contains($0) }
    }

    private func isAfterTzet(for date: Date) -> Bool {
        guard let location = selectedLocation else { return false }
        let zmanim = dependencyContainer.zmanimService.calculateZmanim(
            date: date,
            location: location,
            opinions: userOpinions
        )
        guard let tzet = zmanim.first(where: { $0.id == "tzeit" })?.time else { return false }
        return date >= tzet
    }
}


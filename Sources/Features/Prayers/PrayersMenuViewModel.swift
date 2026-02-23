import Foundation
import Observation
import KosherSwift

@MainActor
@Observable
final class PrayersMenuViewModel {
    // MARK: - State
    private(set) var loadingState: LoadingState = .idle
    private(set) var prayerSections: [PrayerSection] = []
    private(set) var todaysPrayers: [Prayer] = []
    private(set) var errorMessage: String?
    private(set) var visibleSpecialPrayers: Set<PrayerType> = []
    
    // MARK: - Dependencies
    private let prayerService: PrayerService
    private let jewishCalendarService: JewishCalendarService
    private let zmanimService: ZmanimService
    private let localSettings: LocalSettings
    private let cacheService: PrayerCacheService?
    private var userLocation: UserLocation?
    private var syncedSettings: SyncedUserSettings
    
    // MARK: - Visibility Service
    private let visibilityService = PrayerVisibilityService()
    
    // MARK: - Initialization
    init(
        prayerService: PrayerService,
        jewishCalendarService: JewishCalendarService,
        zmanimService: ZmanimService,
        localSettings: LocalSettings,
        syncedSettings: SyncedUserSettings,
        cacheService: PrayerCacheService? = nil
    ) {
        self.prayerService = prayerService
        self.jewishCalendarService = jewishCalendarService
        self.zmanimService = zmanimService
        self.localSettings = localSettings
        self.syncedSettings = syncedSettings
        self.cacheService = cacheService
    }
    
    func updateLocation(_ location: UserLocation) {
        self.userLocation = location
    }
    
    func updateSyncedSettings(_ settings: SyncedUserSettings) {
        self.syncedSettings = settings
    }
    
    // MARK: - Public Methods
    func loadPrayers() async {
        loadingState = .loading
        errorMessage = nil
        
        do {
            let visibilityContext = await buildVisibilityContext()
            visibleSpecialPrayers = visibilityService.visiblePrayers(in: visibilityContext)
            
            let allPrayers = PrayerType.allCases.map { Prayer(type: $0) }
            
            // Filter out special prayers that aren't relevant today
            let filteredPrayers = allPrayers.filter { prayer in
                if prayer.category == .special {
                    return visibleSpecialPrayers.contains(prayer.type)
                }
                return true
            }
            
            prayerSections = filteredPrayers.organizedByCategory()
            
            await loadTodaysPrayers(context: visibilityContext)
            
            if let cacheService = cacheService {
                Task {
                    try? await cacheService.performBackgroundRefreshIfNeeded()
                }
            }
            
            loadingState = .loaded
        } catch {
            errorMessage = error.localizedDescription
            loadingState = .error(error.localizedDescription)
        }
    }
    
    func refreshPrayers() async {
        await loadPrayers()
    }
    
    // MARK: - Private Methods
    private func buildVisibilityContext() async -> PrayerVisibilityContext {
        let today = Date()
        let isInIsrael = syncedSettings.isInIsrael
        let jewishDay = jewishCalendarService.getJewishDay(for: today, isInIsrael: isInIsrael)
        
        let isMotzaeiShabbat = computeIsMotzaeiShabbat()
        let isLevanaAvailable = computeIsLevanaAvailable(jewishDay: jewishDay)
        let isAfterPlagOnErevChanukah = computeIsAfterPlagOnErevChanukah()
        
        return PrayerVisibilityContext(
            jewishDay: jewishDay,
            nusach: syncedSettings.nusach,
            isMotzaeiShabbat: isMotzaeiShabbat,
            isLevanaAvailable: isLevanaAvailable,
            isAfterPlagOnErevChanukah: isAfterPlagOnErevChanukah
        )
    }
    
    private func computeIsMotzaeiShabbat() -> Bool {
        guard let location = userLocation else { return false }
        
        let calendar = Calendar(identifier: .gregorian)
        let dayOfWeek = calendar.component(.weekday, from: Date())
        
        guard dayOfWeek == 1 else { return false }
        
        let zmanimOpinions = ZmanimOpinions(
            dawnOpinion: syncedSettings.dawnOpinion,
            sunriseOpinion: syncedSettings.sunriseOpinion,
            zmanOpinion: syncedSettings.zmanOpinion,
            duskOpinion: syncedSettings.duskOpinion,
            shabbatCandleMinutes: syncedSettings.shabbatCandleMinutes,
            shabbatEndMinutes: syncedSettings.shabbatEndMinutes
        )
        
        let zmanim = zmanimService.calculateZmanim(date: Date(), location: location, opinions: zmanimOpinions)
        
        guard let tzeit = zmanim.first(where: { $0.id == "tzeit" })?.time else {
            return false
        }
        
        return Date() > tzeit
    }
    
    private func computeIsLevanaAvailable(jewishDay: JewishDay) -> Bool {
        let jCal = KosherSwift.JewishCalendar(workingDate: Date())
        
        let earliest = jCal.getTchilasZmanKidushLevana7Days()
        let latest = jCal.getSofZmanKidushLevana15Days()
        
        let now = Date()
        return now >= earliest && now <= latest
    }
    
    private func computeIsAfterPlagOnErevChanukah() -> Bool {
        guard let location = userLocation else { return false }
        
        let jCal = KosherSwift.JewishCalendar(workingDate: Date())
        let isErevChanukah = jCal.getJewishMonth() == KosherSwift.JewishCalendar.KISLEV && 
                             jCal.getJewishDayOfMonth() == 24
        
        guard isErevChanukah else { return false }
        
        let zmanimOpinions = ZmanimOpinions(
            dawnOpinion: syncedSettings.dawnOpinion,
            sunriseOpinion: syncedSettings.sunriseOpinion,
            zmanOpinion: syncedSettings.zmanOpinion,
            duskOpinion: syncedSettings.duskOpinion,
            shabbatCandleMinutes: syncedSettings.shabbatCandleMinutes,
            shabbatEndMinutes: syncedSettings.shabbatEndMinutes
        )
        
        let zmanim = zmanimService.calculateZmanim(date: Date(), location: location, opinions: zmanimOpinions)
        
        guard let plag = zmanim.first(where: { $0.id == "plagHamincha" })?.time else {
            return false
        }
        
        return Date() > plag
    }
    
    private func loadTodaysPrayers(context: PrayerVisibilityContext) async {
        let today = Date()
        
        let allPrayers = PrayerType.allCases.map { Prayer(type: $0) }
        
        todaysPrayers = allPrayers.filter { prayer in
            isPrayerRelevantForToday(prayer, context: context)
        }
        
        if let cacheService = cacheService {
            for i in 0..<todaysPrayers.count {
                let prayer = todaysPrayers[i]
                if let cached = try? await cacheService.getCachedPrayer(type: prayer.type, date: today) {
                }
            }
        }
    }
    
    private func isPrayerRelevantForToday(_ prayer: Prayer, context: PrayerVisibilityContext) -> Bool {
        let type = prayer.type
        
        switch type {
        case .shacharit, .mincha, .arvit:
            return true
            
        case .mazon, .asherYatzar, .blessings, .threefold, .haderech:
            return true
            
        case .alMita, .chatzot:
            return true
            
        case .musaf, .torahReading:
            return context.jewishDay.isShabbat || context.jewishDay.isYomTov || context.jewishDay.isRoshChodesh
            
        case .omer, .lagBaomer, .havdala, .hanuka, .ilanot, .kinot, .slihot, .nedarim, .ushpizin, .levana:
            return visibleSpecialPrayers.contains(type)
            
        case .mila, .shevaBrachot, .maaser, .hala:
            return false
        }
    }
    
    // MARK: - Computed Properties
    var hasTodaysPrayers: Bool {
        !todaysPrayers.isEmpty
    }
    
    var isLoading: Bool {
        if case .loading = loadingState { return true }
        return false
    }
    
    var hasError: Bool {
        errorMessage != nil
    }
}

// MARK: - Loading State
extension PrayersMenuViewModel {
    enum LoadingState: Equatable {
        case idle
        case loading
        case loaded
        case error(String)
        
        static func == (lhs: LoadingState, rhs: LoadingState) -> Bool {
            switch (lhs, rhs) {
            case (.idle, .idle), (.loading, .loading), (.loaded, .loaded):
                return true
            case (.error(let lhsMessage), .error(let rhsMessage)):
                return lhsMessage == rhsMessage
            default:
                return false
            }
        }
    }
}

// MARK: - Prayer Section Extensions
extension PrayersMenuViewModel {
    func prayersForSection(_ section: PrayerSection) -> [Prayer] {
        return section.prayers.sorted { lhs, rhs in
            return prayerOrderValue(lhs.type) < prayerOrderValue(rhs.type)
        }
    }
    
    private func prayerOrderValue(_ type: PrayerType) -> Int {
        switch type {
        case .shacharit: return 0
        case .mincha: return 0
        case .arvit: return 0
        case .alMita: return 1
        case .chatzot: return 2
        case .musaf: return 0
        case .torahReading: return 1
        case .mazon: return 0
        case .asherYatzar: return 1
        case .blessings: return 2
        case .threefold: return 3
        case .haderech: return 4
        case .mila: return 5
        case .shevaBrachot: return 6
        case .maaser: return 7
        case .hala: return 8
        case .omer: return 0
        case .havdala: return 1
        case .hanuka: return 2
        case .levana: return 3
        case .slihot: return 4
        case .kinot: return 5
        case .nedarim: return 6
        case .ushpizin: return 7
        case .lagBaomer: return 8
        case .ilanot: return 9
        }
    }
}

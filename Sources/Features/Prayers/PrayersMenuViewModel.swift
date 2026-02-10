import Foundation
import Observation

@MainActor
@Observable
final class PrayersMenuViewModel {
    // MARK: - State
    private(set) var loadingState: LoadingState = .idle
    private(set) var prayerSections: [PrayerSection] = []
    private(set) var todaysPrayers: [Prayer] = []
    private(set) var errorMessage: String?
    
    // MARK: - Dependencies
    private let prayerService: PrayerService
    private let jewishCalendarService: JewishCalendarService
    private let localSettings: LocalSettings
    private let cacheService: PrayerCacheService?
    
    // MARK: - Initialization
    init(
        prayerService: PrayerService,
        jewishCalendarService: JewishCalendarService,
        localSettings: LocalSettings,
        cacheService: PrayerCacheService? = nil
    ) {
        self.prayerService = prayerService
        self.jewishCalendarService = jewishCalendarService
        self.localSettings = localSettings
        self.cacheService = cacheService
    }
    
    // MARK: - Public Methods
    func loadPrayers() async {
        loadingState = .loading
        errorMessage = nil
        
        do {
            // Get all prayer types
            let allPrayers = PrayerType.allCases.map { Prayer(type: $0) }
            
            // Organize by category
            prayerSections = allPrayers.organizedByCategory()
            
            // Get today's relevant prayers from cache when available
            await loadTodaysPrayers()
            
            // Trigger background prefetch for upcoming prayers if cache is available
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
    private func loadTodaysPrayers() async {
        let today = Date()
        // Get isInIsrael from synced settings (default to false)
        let isInIsrael = false
        let jewishDay = jewishCalendarService.getJewishDay(for: today, isInIsrael: isInIsrael)
        
        // Get all prayers and filter for today's relevance
        let allPrayers = PrayerType.allCases.map { Prayer(type: $0) }
        
        todaysPrayers = allPrayers.filter { prayer in
            isPrayerRelevantForToday(prayer, jewishDay: jewishDay)
        }
        
        // Check cache availability for each prayer (for offline indicator)
        if let cacheService = cacheService {
            for i in 0..<todaysPrayers.count {
                let prayer = todaysPrayers[i]
                if let cached = try? await cacheService.getCachedPrayer(type: prayer.type, date: today) {
                    // Prayer is cached and available offline
                    // Could update a cached status property here if needed
                }
            }
        }
    }
    
    private func isPrayerRelevantForToday(_ prayer: Prayer, jewishDay: JewishDay) -> Bool {
        switch prayer.type {
        // Daily prayers are always relevant
        case .shacharit, .mincha, .arvit:
            return true
            
        // Prayers relevant every day
        case .mazon, .asherYatzar, .blessings, .threefold, .haderech:
            return true
            
        // Evening-related
        case .alMita, .chatzot:
            return true
            
        // Musaf on Shabbat/Yom Tov/Rosh Chodesh
        case .musaf:
            return jewishDay.isShabbat || jewishDay.isYomTov || jewishDay.isRoshChodesh
            
        // Torah reading on relevant days
        case .torahReading:
            return jewishDay.isShabbat || jewishDay.isYomTov || jewishDay.isRoshChodesh
            
        // Havdala after Shabbat
        case .havdala:
            return jewishDay.isShabbat
            
        // Omer counting between Pesach and Shavuot
        case .omer:
            return jewishDay.omerDay != nil
            
        // Chanukah
        case .hanuka:
            return false // Could check holiday name in jewishDay
            
        // Selichot in Elul / Aseret Yemei Teshuva
        case .slihot:
            return false // No Elul info in current JewishDay
            
        // Kinot for Tisha B'Av
        case .kinot:
            return jewishDay.isTaanis
            
        // Special occasion prayers — not daily
        case .levana, .mila, .shevaBrachot, .maaser, .hala,
             .lagBaomer, .ilanot, .nedarim, .ushpizin:
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
            // Sort by importance/sequence within each category
            return prayerOrderValue(lhs.type) < prayerOrderValue(rhs.type)
        }
    }
    
    private func prayerOrderValue(_ type: PrayerType) -> Int {
        // Define prayer importance/sequence order within each category
        switch type {
        // Morning prayer
        case .shacharit: return 0
        
        // Afternoon prayer
        case .mincha: return 0
        
        // Evening prayers
        case .arvit: return 0
        case .alMita: return 1
        case .chatzot: return 2
        
        // Special prayers - by frequency/importance
        case .musaf: return 0
        case .torahReading: return 1
        case .mazon: return 2
        case .asherYatzar: return 3
        case .blessings: return 4
        case .threefold: return 5
        case .omer: return 6
        case .havdala: return 7
        case .haderech: return 8
        case .levana: return 9
        case .hanuka: return 10
        case .slihot: return 11
        case .kinot: return 12
        case .mila: return 13
        case .shevaBrachot: return 14
        case .maaser: return 15
        case .hala: return 16
        case .lagBaomer: return 17
        case .ilanot: return 18
        case .nedarim: return 19
        case .ushpizin: return 20
        }
    }
}
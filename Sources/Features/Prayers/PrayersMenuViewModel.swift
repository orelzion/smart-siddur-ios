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
    
    // MARK: - Initialization
    init(
        prayerService: PrayerService,
        jewishCalendarService: JewishCalendarService,
        localSettings: LocalSettings
    ) {
        self.prayerService = prayerService
        self.jewishCalendarService = jewishCalendarService
        self.localSettings = localSettings
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
            
            // Get today's relevant prayers
            await loadTodaysPrayers()
            
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
        let jewishDay = jewishCalendarService.getJewishDay(for: today)
        
        // Get all prayers and filter for today's relevance
        let allPrayers = PrayerType.allCases.map { Prayer(type: $0) }
        
        todaysPrayers = allPrayers.filter { prayer in
            isPrayerRelevantForToday(prayer, jewishDay: jewishDay)
        }
    }
    
    private func isPrayerRelevantForToday(_ prayer: Prayer, jewishDay: JewishDay) -> Bool {
        // Daily prayers are always relevant
        switch prayer.type {
        case .shacharit, .mincha, .arvit, .shema:
            return true
            
        // Special occasion prayers
        case .hallel:
            return jewishDay.isRoshChodesh || jewishDay.isYomTov || jewishDay.isPesach
            
        case .musaf:
            return jewishDay.isShabbat || jewishDay.isYomTov
            
        case .selichot:
            return jewishDay.isElul || jewishDay.isAseretYemeiTeshuva
            
        case .vidui, .alChet:
            return jewishDay.isYomKippur || jewishDay.isTaanit
            
        case .avodah:
            return jewishDay.isYomKippur
            
        // Morning-specific prayers
        case .birchotHaShachar, .psukeiDezimra, .korbanot, .tachanun:
            return true
            
        // Afternoon-specific prayers
        case .minchaGedola, .minchaKetana, .neilat:
            return true
            
        // Evening-specific prayers
        case .kriatShemaAlHaMitah, .chatzot:
            return true
            
        // Always include special prayers that might be relevant
        case .kriatHaTorah, .aleinu, .kaddish, .barchu, .kedusha, .amidah, .ashrei, .lamnatzeach:
            return true
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
        // Define prayer importance/sequence order
        switch type {
        // Morning prayers - main service first
        case .shacharit: return 0
        case .birchotHaShachar: return 1
        case .korbanot: return 2
        case .psukeiDezimra: return 3
        case .tachanun: return 4
        
        // Afternoon prayers
        case .mincha: return 0
        case .minchaGedola: return 1
        case .minchaKetana: return 2
        case .neilat: return 3
        
        // Evening prayers
        case .arvit: return 0
        case .kriatShemaAlHaMitah: return 1
        case .chatzot: return 2
        
        // Special prayers - by importance
        case .musaf: return 0
        case .hallel: return 1
        case .kriatHaTorah: return 2
        case .amidah: return 3
        case .kedusha: return 4
        case .kaddish: return 5
        case .aleinu: return 6
        case .ashrei: return 7
        case .shema: return 8
        case .barchu: return 9
        
        // Penitential prayers
        case .vidui: return 0
        case .alChet: return 1
        case .selichot: return 2
        case .avodah: return 3
        
        // Other special prayers
        case .lamnatzeach: return 0
        }
    }
}
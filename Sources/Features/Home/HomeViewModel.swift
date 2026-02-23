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
    private let zmanimService: ZmanimService
    private let authViewModel: AuthViewModel
    private let dependencyContainer: DependencyContainer
    
    private let logger = Logger(subsystem: "com.karriapps.smartsiddur", category: "HomeViewModel")
    
    var greetingText: String = ""
    var dateText: String = ""
    var nextPrayerState: NextPrayerState? = nil
    var suggestedItems: [SuggestedItem] = []
    var seasonalBadgeText: String?
    var filteredPrayers: [PrayerType] = [.shacharit, .mincha, .arvit, .mazon]
    var currentJewishDay: JewishDay?
    var isLoading = false
    
    private var updateTimer: Timer?
    
    init(
        dependencyContainer: DependencyContainer,
        nextPrayerService: NextPrayerService? = nil,
        prayerVisibilityService: PrayerVisibilityService? = nil,
        jewishCalendarService: JewishCalendarService? = nil,
        zmanimService: ZmanimService? = nil,
        authViewModel: AuthViewModel? = nil
    ) {
        self.dependencyContainer = dependencyContainer
        
        self.nextPrayerService = nextPrayerService ?? NextPrayerService(
            zmanimService: dependencyContainer.zmanimService,
            jewishCalendarService: dependencyContainer.jewishCalendarService
        )
        self.prayerVisibilityService = prayerVisibilityService ?? PrayerVisibilityService()
        self.jewishCalendarService = jewishCalendarService ?? dependencyContainer.jewishCalendarService
        self.zmanimService = zmanimService ?? dependencyContainer.zmanimService
        self.authViewModel = authViewModel ?? AuthViewModel(authRepository: dependencyContainer.authRepository)
        
        updateDisplay()
    }
    
    func start() {
        logger.debug("Starting HomeViewModel")
        updateDisplay()
        
        Task {
            await refreshData()
        }
        
        updateTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateDisplay()
            }
        }
    }
    
    func stop() {
        logger.debug("Stopping HomeViewModel")
        updateTimer?.invalidate()
        updateTimer = nil
    }
    
    private func refreshData() async {
        isLoading = true
        updateDisplay()
        
        let today = Date()
        suggestedItems = prayerVisibilityService.suggestedItems(for: today)
        seasonalBadgeText = jewishCalendarService.seasonalBadge(for: today)
        
        isLoading = false
    }
    
    private func updateDisplay() {
        updateGreeting()
        updateDates(for: Date())
        updateJewishDayInfo(for: Date())
    }
    
    private func updateGreeting() {
        let hour = Calendar.current.component(.hour, from: Date())
        let timeGreeting: String
        
        switch hour {
        case 5..<12:
            timeGreeting = "Boker tov"
        case 12..<17:
            timeGreeting = "Tzom hari"
        case 17..<20:
            timeGreeting = "Erev tov"
        default:
            timeGreeting = "Shalom"
        }
        
        if let displayName = authViewModel.displayName {
            greetingText = "\(timeGreeting), \(displayName)"
        } else {
            greetingText = timeGreeting
        }
    }
    
    private func updateDates(for date: Date) {
        let gregorianFormatter = DateFormatter()
        gregorianFormatter.dateStyle = .medium
        gregorianFormatter.locale = Locale(identifier: "en_US")
        let gregorianStr = gregorianFormatter.string(from: date)
        
        if let jewishDay = currentJewishDay {
            dateText = "\(jewishDay.hebrewDateString) | \(gregorianStr)"
        } else {
            dateText = gregorianStr
        }
    }
    
    private func updateJewishDayInfo(for date: Date) {
        let isInIsrael = dependencyContainer.localSettings.locationName?.contains("Israel") == true
        self.currentJewishDay = jewishCalendarService.getJewishDay(for: date, isInIsrael: isInIsrael)
    }
}

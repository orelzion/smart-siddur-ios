import Foundation
import Observation
import SwiftUI
import OSLog

/// Manages the state and logic for the Home tab.
///
/// This view model:
/// - Manages greeting text and date display
/// - Coordinates NextPrayerService for countdown information
/// - Manages suggested items from PrayerVisibilityService
/// - Provides seasonal badge from JewishCalendarService
/// - Filters prayer grid with consistent logic (always show: Shacharit, Mincha, Arvit, etc.)
/// - Handles lifecycle and timer management
@MainActor
@Observable
final class HomeViewModel {
    private let nextPrayerService: NextPrayerService
    private let prayerVisibilityService: PrayerVisibilityService
    private let jewishCalendarService: JewishCalendarService
    private let zmanimService: ZmanimService
    private let authViewModel: AuthViewModel
    
    private let logger = Logger(subsystem: "com.karriapps.smartsiddur", category: "HomeViewModel")
    
    // MARK: - Published Properties
    
    /// Greeting text (e.g., "Good morning, [name]" or "Boker tov")
    var greetingText: String = ""
    
    /// Today's Hebrew and Gregorian dates
    var dateText: String = ""
    
    /// Current state of the next prayer
    var nextPrayerState: NextPrayerState = .empty
    
    /// Suggested items for the "Suggested For You" section
    var suggestedItems: [SuggestedItem] = []
    
    /// Seasonal badge text (e.g., "Chanukah night 3", "Sefirat HaOmer night 5")
    var seasonalBadge: String?
    
    /// All visible prayers for the grid (filtered)
    var gridPrayers: [Prayer] = []
    
    /// Current Jewish day information
    var currentJewishDay: JewishDay?
    
    /// Scene phase for lifecycle management
    var scenePhase: ScenePhase = .active {
        didSet {
            nextPrayerService.scenePhase = scenePhase
        }
    }
    
    // MARK: - Dependencies
    
    let dependencyContainer: DependencyContainer
    
    init(
        dependencyContainer: DependencyContainer,
        nextPrayerService: NextPrayerService? = nil,
        prayerVisibilityService: PrayerVisibilityService? = nil,
        jewishCalendarService: JewishCalendarService? = nil,
        zmanimService: ZmanimService? = nil,
        authViewModel: AuthViewModel? = nil
    ) {
        self.dependencyContainer = dependencyContainer
        
        // Use provided services or create new ones / get from container
        self.nextPrayerService = nextPrayerService ?? NextPrayerService(
            zmanimService: dependencyContainer.zmanimService,
            jewishCalendarService: dependencyContainer.jewishCalendarService
        )
        self.prayerVisibilityService = prayerVisibilityService ?? PrayerVisibilityService()
        self.jewishCalendarService = jewishCalendarService ?? dependencyContainer.jewishCalendarService
        self.zmanimService = zmanimService ?? dependencyContainer.zmanimService
        self.authViewModel = authViewModel ?? AuthViewModel(repository: dependencyContainer.authRepository)
        
        // Initial setup
        updateDisplay()
    }
    
    /// Start monitoring for updates.
    func start() {
        logger.debug("Starting HomeViewModel")
        updateDisplay()
        
        // Start next prayer service with current location/opinions
        Task {
            let location = await getCurrentLocation()
            let opinions = getZmanimOpinions()
            nextPrayerService.startMonitoring(location: location, opinions: opinions)
        }
    }
    
    /// Stop monitoring.
    func stop() {
        logger.debug("Stopping HomeViewModel")
        nextPrayerService.stopMonitoring()
    }
    
    /// Update display with current date/time information.
    func updateDisplay() {
        let now = Date()
        updateGreeting()
        updateDates(for: now)
        updateJewishDayInfo(for: now)
        
        // Get location and opinions for the data
        Task {
            let location = await getCurrentLocation()
            let opinions = getZmanimOpinions()
            
            // Update suggested items
            if let jewishDay = currentJewishDay {
                self.suggestedItems = prayerVisibilityService.suggestedItems(
                    for: now,
                    jewishDay: jewishDay
                )
                
                // Update seasonal badge
                self.seasonalBadge = jewishCalendarService.seasonalBadge(for: jewishDay)
            }
            
            // Update prayer grid
            self.gridPrayers = getFilteredPrayersForGrid(
                location: location,
                opinions: opinions,
                for: now
            )
        }
    }
    
    // MARK: - Private Helpers
    
    private func updateGreeting() {
        // Greeting based on time of day and user name
        let hour = Calendar.current.component(.hour, from: Date())
        let timeGreeting: String
        
        switch hour {
        case 5..<12:
            timeGreeting = "Good morning"
        case 12..<17:
            timeGreeting = "Good afternoon"
        case 17..<21:
            timeGreeting = "Good evening"
        default:
            timeGreeting = "Shalom"
        }
        
        // Get user name if available
        if let userProfile = authViewModel.userProfile {
            greetingText = "\(timeGreeting), \(userProfile.displayName ?? "Friend")"
        } else {
            greetingText = timeGreeting
        }
    }
    
    private func updateDates(for date: Date) {
        let gregorianFormatter = DateFormatter()
        gregorianFormatter.dateStyle = .medium
        gregorianFormatter.locale = Locale(identifier: "en_US")
        let gregorianStr = gregorianFormatter.string(from: date)
        
        // Get Hebrew date
        if let jewishDay = currentJewishDay {
            dateText = "\(jewishDay.hebrewDateString) | \(gregorianStr)"
        } else {
            dateText = gregorianStr
        }
    }
    
    private func updateJewishDayInfo(for date: Date) {
        let isInIsrael = dependencyContainer.localSettings.isInIsrael
        self.currentJewishDay = jewishCalendarService.getJewishDay(for: date, isInIsrael: isInIsrael)
    }
    
    private func getCurrentLocation() async -> UserLocation {
        // Try to get user's selected location, fallback to default
        if let locationName = dependencyContainer.selectedLocationName {
            // In production, we'd fetch this from the location repo
            // For now, return a placeholder with the location name
            return UserLocation(
                id: locationName,
                name: locationName,
                latitude: 31.7683,
                longitude: 35.2137,
                elevation: 754,
                timezoneId: "Asia/Jerusalem",
                countryCode: "IL",
                isInIsrael: true
            )
        }
        
        // Default to Jerusalem
        return UserLocation(
            id: "jerusalem",
            name: "Jerusalem",
            latitude: 31.7683,
            longitude: 35.2137,
            elevation: 754,
            timezoneId: "Asia/Jerusalem",
            countryCode: "IL",
            isInIsrael: true
        )
    }
    
    private func getZmanimOpinions() -> ZmanimOpinions {
        // Get opinions from synced settings (in practice)
        // For now, return defaults
        return .defaults
    }
    
    private func getFilteredPrayersForGrid(
        location: UserLocation,
        opinions: ZmanimOpinions,
        for date: Date
    ) -> [Prayer] {
        let isInIsrael = location.countryCode == "IL"
        let jewishDay = jewishCalendarService.getJewishDay(for: date, isInIsrael: isInIsrael)
        
        let nusach = dependencyContainer.localSettings.nusach
        
        var visiblePrayers = Set<PrayerType>([
            .shacharit,  // Always show
            .mincha,     // Always show
            .arvit,      // Always show
            .mazon,      // Always show
            .asherYatzar // Always show
        ])
        
        // Add special prayers
        let context = PrayerVisibilityContext(
            jewishDay: jewishDay,
            nusach: nusach,
            isMotzaeiShabbat: false, // Would be determined from time
            isLevanaAvailable: false, // Would be determined from moon data
            isAfterPlagOnErevChanukah: false // Would be determined from time
        )
        
        let specialPrayers = prayerVisibilityService.visiblePrayers(in: context)
        visiblePrayers.formUnion(specialPrayers)
        
        // Create Prayer objects
        let prayers = visiblePrayers.map { Prayer(type: $0) }
        
        // Sort by category and name
        return prayers.sorted { a, b in
            let catOrder: [PrayerCategory] = [.daily, .blessings, .special]
            let catA = catOrder.firstIndex(of: a.category) ?? 999
            let catB = catOrder.firstIndex(of: b.category) ?? 999
            
            if catA != catB {
                return catA < catB
            }
            return a.displayName < b.displayName
        }
    }
}

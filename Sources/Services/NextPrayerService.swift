import Foundation
import Observation
import SwiftUI
import OSLog

@MainActor
@Observable
final class NextPrayerService {
    private let zmanimService: ZmanimService
    private let jewishCalendarService: JewishCalendarService
    private let logger = Logger(subsystem: "com.karriapps.smartsiddur", category: "NextPrayerService")
    
    var state: NextPrayerState = .empty
    
    init(zmanimService: ZmanimService, jewishCalendarService: JewishCalendarService) {
        self.zmanimService = zmanimService
        self.jewishCalendarService = jewishCalendarService
    }
    
    func startMonitoring(location: UserLocation, opinions: ZmanimOpinions) {
        logger.debug("Starting next prayer monitoring")
    }
    
    func stopMonitoring() {
        logger.debug("Stopping next prayer monitoring")
    }
    
    func calculateCurrentMilestone(for date: Date, location: UserLocation, isInIsrael: Bool) -> PrayerMilestone {
        let hour = Calendar.current.component(.hour, from: date)
        
        if hour < 12 {
            return PrayerMilestone(
                name: "Shacharit",
                hebrewName: "שחרית",
                time: date,
                halachicDescription: "Morning prayer"
            )
        } else if hour < 16 {
            return PrayerMilestone(
                name: "Mincha",
                hebrewName: "מנחה",
                time: date,
                halachicDescription: "Afternoon prayer"
            )
        } else {
            return PrayerMilestone(
                name: "Arvit",
                hebrewName: "ערבית",
                time: date,
                halachicDescription: "Evening prayer"
            )
        }
    }
}

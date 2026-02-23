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
    
    func calculateCurrentState(
        for date: Date,
        location: UserLocation,
        opinions: ZmanimOpinions,
        isInIsrael: Bool
    ) -> NextPrayerState {
        let calendar = Calendar.current
        guard
            let today = zmanimMap(for: date, location: location, opinions: opinions),
            let yesterdayDate = calendar.date(byAdding: .day, value: -1, to: date),
            let yesterday = zmanimMap(for: yesterdayDate, location: location, opinions: opinions),
            let tomorrowDate = calendar.date(byAdding: .day, value: 1, to: date),
            let tomorrow = zmanimMap(for: tomorrowDate, location: location, opinions: opinions)
        else {
            logger.error("Unable to calculate zmanim window. Falling back to hour-based milestone")
            return fallbackState(for: date)
        }

        let alotToday = today["alot"] ?? .distantFuture
        let netzToday = today["netz"] ?? .distantFuture
        let sofShmaToday = today["sofZmanShma"] ?? .distantFuture
        let sofTefilaToday = today["sofZmanTfila"] ?? .distantFuture
        let chatzotToday = today["chatzot"] ?? .distantFuture
        let minchaGedolaToday = today["minchaGedola"] ?? .distantFuture
        let shkiaToday = today["shkia"] ?? .distantFuture
        let tzetToday = today["tzeit"] ?? .distantFuture
        let chatzotLaylaToday = today["chatzotHalaila"] ?? .distantFuture
        let chatzotLaylaYesterday = yesterday["chatzotHalaila"] ?? .distantPast
        let alotTomorrow = tomorrow["alot"] ?? .distantFuture

        if date >= chatzotLaylaYesterday && date < alotToday {
            return makeState(
                prayer: .arvit,
                milestone: .init(
                    name: "Alot HaShachar",
                    hebrewName: "עלות השחר",
                    time: alotToday,
                    halachicDescription: "Dawn"
                )
            )
        }

        if date >= alotToday && date < netzToday {
            return makeState(
                prayer: .shacharit,
                milestone: .init(
                    name: "Netz HaChama",
                    hebrewName: "נץ החמה",
                    time: netzToday,
                    halachicDescription: "Sunrise - earliest preferred Shacharit"
                )
            )
        }

        if date >= netzToday && date < sofShmaToday {
            return makeState(
                prayer: .shacharit,
                milestone: .init(
                    name: "Sof Zman Kriat Shma",
                    hebrewName: "סוף זמן קריאת שמע",
                    time: sofShmaToday,
                    halachicDescription: "Last time to recite Shma - GR\"A"
                )
            )
        }

        if date >= sofShmaToday && date < sofTefilaToday {
            return makeState(
                prayer: .shacharit,
                milestone: .init(
                    name: "Sof Zman Tefila",
                    hebrewName: "סוף זמן תפילה",
                    time: sofTefilaToday,
                    halachicDescription: "Last time for Amida - GR\"A"
                )
            )
        }

        if date >= sofTefilaToday && date < chatzotToday {
            return makeState(
                prayer: .shacharit,
                milestone: .init(
                    name: "Chatzot HaYom",
                    hebrewName: "חצות היום",
                    time: chatzotToday,
                    halachicDescription: "Midday - last time for Shacharit makeup"
                )
            )
        }

        if date >= chatzotToday && date < minchaGedolaToday {
            return makeState(
                prayer: nil,
                milestone: .init(
                    name: "Mincha Gedola",
                    hebrewName: "מנחה גדולה",
                    time: minchaGedolaToday,
                    halachicDescription: "Mincha begins in..."
                )
            )
        }

        if date >= minchaGedolaToday && date < shkiaToday {
            return makeState(
                prayer: .mincha,
                milestone: .init(
                    name: "Shkia",
                    hebrewName: "שקיעה",
                    time: shkiaToday,
                    halachicDescription: "Sunset"
                )
            )
        }

        if date >= shkiaToday && date < tzetToday {
            return NextPrayerState(
                prayer: nil,
                currentMilestone: .init(
                    name: "Tzet HaKochavim",
                    hebrewName: "צאת הכוכבים",
                    time: tzetToday,
                    halachicDescription: "Between Mincha & Arvit"
                ),
                isTransitional: true,
                alternativePrayer: .arvit
            )
        }

        if date >= tzetToday && date < chatzotLaylaToday {
            return makeState(
                prayer: .arvit,
                milestone: .init(
                    name: "Chatzot Layla",
                    hebrewName: "חצות לילה",
                    time: chatzotLaylaToday,
                    halachicDescription: "Halachic midnight"
                )
            )
        }

        if date >= chatzotLaylaToday && date < alotTomorrow {
            return makeState(
                prayer: .arvit,
                milestone: .init(
                    name: "Alot HaShachar",
                    hebrewName: "עלות השחר",
                    time: alotTomorrow,
                    halachicDescription: "Dawn"
                )
            )
        }

        _ = isInIsrael
        return fallbackState(for: date)
    }

    func calculateCurrentMilestone(for date: Date, location: UserLocation, isInIsrael: Bool) -> PrayerMilestone {
        _ = isInIsrael
        return calculateCurrentState(
            for: date,
            location: location,
            opinions: .defaults,
            isInIsrael: false
        ).currentMilestone
    }

    private func makeState(prayer: PrayerType?, milestone: PrayerMilestone) -> NextPrayerState {
        NextPrayerState(
            prayer: prayer,
            currentMilestone: milestone,
            isTransitional: false,
            alternativePrayer: nil
        )
    }

    private func fallbackState(for date: Date) -> NextPrayerState {
        let hour = Calendar.current.component(.hour, from: date)
        if hour < 12 {
            return makeState(
                prayer: .shacharit,
                milestone: PrayerMilestone(
                    name: "Netz HaChama",
                    hebrewName: "נץ החמה",
                    time: date,
                    halachicDescription: "Sunrise - earliest preferred Shacharit"
                )
            )
        }
        if hour < 18 {
            return makeState(
                prayer: .mincha,
                milestone: PrayerMilestone(
                    name: "Shkia",
                    hebrewName: "שקיעה",
                    time: date,
                    halachicDescription: "Sunset"
                )
            )
        }
        return makeState(
            prayer: .arvit,
            milestone: PrayerMilestone(
                name: "Chatzot Layla",
                hebrewName: "חצות לילה",
                time: date,
                halachicDescription: "Halachic midnight"
            )
        )
    }

    private func zmanimMap(
        for date: Date,
        location: UserLocation,
        opinions: ZmanimOpinions
    ) -> [String: Date]? {
        let zmanim = zmanimService.calculateZmanim(date: date, location: location, opinions: opinions)
        let map = Dictionary(uniqueKeysWithValues: zmanim.compactMap { zman -> (String, Date)? in
            guard let time = zman.time else {
                return nil
            }
            return (zman.id, time)
        })
        return map.isEmpty ? nil : map
    }
}

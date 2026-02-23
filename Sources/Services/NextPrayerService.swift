import Foundation
import Observation
import SwiftUI
import OSLog

/// Manages the state of the next prayer to be observed, with smart milestone tracking.
///
/// This service:
/// - Calculates which prayer is current/next based on time windows
/// - Updates state only at milestone boundaries (not every second) for efficiency
/// - Observes scene phase changes to recalculate when returning from background
/// - Provides @Published state for SwiftUI binding
///
/// The service divides each prayer's accessible time into 9 windows:
/// 1. Before the prayer time
/// 2-6. Various minutes before (30, 15, 10, 5, 1)
/// 7. During Halachic Time (best prayer window)
/// 8. During Extended Time (still permitted)
/// 9. Too late (prayer time has passed)
@MainActor
@Observable
final class NextPrayerService {
    private let zmanimService: ZmanimService
    private let jewishCalendarService: JewishCalendarService
    private let logger = Logger(subsystem: "com.karriapps.smartsiddur", category: "NextPrayerService")
    
    @ObservationIgnored
    private var timer: Timer?
    
    @ObservationIgnored
    private var lastMilestoneCheckTime: Date = Date()
    
    /// The current state of the next prayer
    var state: NextPrayerState = .empty {
        didSet {
            logger.debug("Next prayer state changed: \(self.state.prayer.displayName) - \(self.state.currentMilestone.name)")
        }
    }
    
    /// Scene phase for detecting background/foreground transitions
    @ObservationIgnored
    var scenePhase: ScenePhase = .active {
        didSet {
            if oldValue != .active && scenePhase == .active {
                logger.debug("App returned to foreground, recalculating next prayer")
                // Force recalculation when returning to foreground
                Task {
                    await updateState()
                }
            }
        }
    }
    
    init(zmanimService: ZmanimService, jewishCalendarService: JewishCalendarService) {
        self.zmanimService = zmanimService
        self.jewishCalendarService = jewishCalendarService
    }
    
    /// Start monitoring next prayer state with timer at milestone boundaries.
    func startMonitoring(location: UserLocation, opinions: ZmanimOpinions) {
        logger.debug("Starting next prayer monitoring")
        
        // Initial calculation
        Task {
            await updateState(location: location, opinions: opinions)
        }
        
        // Timer that checks every 5 seconds if we've crossed a milestone boundary
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            Task { [weak self] in
                await self?.checkMilestoneUpdate(location: location, opinions: opinions)
            }
        }
    }
    
    /// Stop monitoring next prayer state.
    func stopMonitoring() {
        logger.debug("Stopping next prayer monitoring")
        timer?.invalidate()
        timer = nil
    }
    
    /// Update state, checking if we've crossed a milestone boundary.
    /// Only updates if the milestone has actually changed.
    private func checkMilestoneUpdate(location: UserLocation, opinions: ZmanimOpinions) {
        let now = Date()
        // Only check every 5 seconds, and only if at least 5 seconds has passed
        guard now.timeIntervalSince(lastMilestoneCheckTime) >= 5.0 else { return }
        
        let newState = calculateNextPrayerState(
            date: now,
            location: location,
            opinions: opinions
        )
        
        // Only update if milestone name changed (avoid constant updates)
        if newState.currentMilestone.name != state.currentMilestone.name ||
           newState.prayer != state.prayer {
            self.state = newState
            lastMilestoneCheckTime = now
        }
    }
    
    /// Manually update state with location and opinions.
    func updateState(location: UserLocation, opinions: ZmanimOpinions) async {
        let newState = calculateNextPrayerState(
            date: Date(),
            location: location,
            opinions: opinions
        )
        self.state = newState
        lastMilestoneCheckTime = Date()
    }
    
    /// Calculate the next prayer state for a given date, location, and opinions.
    private func calculateNextPrayerState(
        date: Date,
        location: UserLocation,
        opinions: ZmanimOpinions
    ) -> NextPrayerState {
        // Get zmanim for the day
        let zmanim = zmanimService.calculateZmanim(date: date, location: location, opinions: opinions)
        let jewishDay = jewishCalendarService.getJewishDay(for: date, isInIsrael: location.countryCode == "IL")
        
        // Map prayer times from zmanim
        let shacharitStart = findZman(zmanim, id: "netz")?.time
        let sofZmanTfila = findZman(zmanim, id: "sofZmanTfila")?.time
        let minchaGedola = findZman(zmanim, id: "minchaGedola")?.time
        let minchaKetana = findZman(zmanim, id: "minchaKetana")?.time
        let plagHamincha = findZman(zmanim, id: "plagHamincha")?.time
        let shkia = findZman(zmanim, id: "shkia")?.time
        let tzeit = findZman(zmanim, id: "tzeit")?.time
        
        let now = date
        
        // Determine current prayer and milestone
        // Order: Shacharit -> Mincha -> Arvit
        
        // SHACHARIT: Sunrise to Sof Zman Tfila
        if let shacharitStart = shacharitStart, let sofZman = sofZmanTfila {
            if now < shacharitStart {
                let timeUntil = shacharitStart.timeIntervalSince(now)
                return NextPrayerState(
                    prayer: .shacharit,
                    currentMilestone: milestoneForMinutesBefore(
                        Int(timeUntil / 60),
                        prayerName: "Shacharit",
                        hebrewName: "שחרית",
                        zmanTime: shacharitStart
                    ),
                    isTransitional: false,
                    alternativePrayer: nil
                )
            } else if now <= sofZman {
                return NextPrayerState(
                    prayer: .shacharit,
                    currentMilestone: PrayerMilestone(
                        name: "Now",
                        hebrewName: "עכשיו",
                        time: sofZman,
                        halachicDescription: "Shacharit is in its halachic time window"
                    ),
                    isTransitional: false,
                    alternativePrayer: nil
                )
            }
        }
        
        // MINCHA: Mincha Gedola to Plag HaMincha (with extended until Tzeit)
        if let minchaStart = minchaGedola, let plagHamin = plagHamincha {
            if now < minchaStart {
                let timeUntil = minchaStart.timeIntervalSince(now)
                return NextPrayerState(
                    prayer: .mincha,
                    currentMilestone: milestoneForMinutesBefore(
                        Int(timeUntil / 60),
                        prayerName: "Mincha",
                        hebrewName: "מנחה",
                        zmanTime: minchaStart
                    ),
                    isTransitional: false,
                    alternativePrayer: nil
                )
            } else if now <= plagHamin {
                return NextPrayerState(
                    prayer: .mincha,
                    currentMilestone: PrayerMilestone(
                        name: "Now",
                        hebrewName: "עכשיו",
                        time: plagHamin,
                        halachicDescription: "Mincha is in its prime time window"
                    ),
                    isTransitional: false,
                    alternativePrayer: nil
                )
            } else if let tzeitTime = tzeit, now <= tzeitTime {
                // Extended Mincha time until Tzeit
                return NextPrayerState(
                    prayer: .mincha,
                    currentMilestone: PrayerMilestone(
                        name: "Extended",
                        hebrewName: "שעת התפילה המורחבת",
                        time: tzeitTime,
                        halachicDescription: "Mincha can still be said, but should be quick"
                    ),
                    isTransitional: true,
                    alternativePrayer: .arvit
                )
            }
        }
        
        // ARVIT: After Tzeit
        if let tzeitTime = tzeit {
            if now < tzeitTime {
                let timeUntil = tzeitTime.timeIntervalSince(now)
                // Special case: if close to Shkia-Tzeit window, show Arvit as alternative
                if let shkiaTime = shkia, now >= shkiaTime {
                    return NextPrayerState(
                        prayer: .mincha,
                        currentMilestone: PrayerMilestone(
                            name: "Shkia to Tzeit",
                            hebrewName: "בין שקיעה לצאת",
                            time: tzeitTime,
                            halachicDescription: "Window for Arvit to be said"
                        ),
                        isTransitional: true,
                        alternativePrayer: .arvit
                    )
                } else {
                    return NextPrayerState(
                        prayer: .arvit,
                        currentMilestone: milestoneForMinutesBefore(
                            Int(timeUntil / 60),
                            prayerName: "Arvit",
                            hebrewName: "ערבית",
                            zmanTime: tzeitTime
                        ),
                        isTransitional: false,
                        alternativePrayer: nil
                    )
                }
            } else {
                // After Tzeit - Arvit is now available
                return NextPrayerState(
                    prayer: .arvit,
                    currentMilestone: PrayerMilestone(
                        name: "Now",
                        hebrewName: "עכשיו",
                        time: tzeitTime,
                        halachicDescription: "Arvit is available until midnight"
                    ),
                    isTransitional: false,
                    alternativePrayer: nil
                )
            }
        }
        
        // Fallback
        return .empty
    }
    
    /// Create a milestone for N minutes before prayer time.
    private func milestoneForMinutesBefore(
        _ minutes: Int,
        prayerName: String,
        hebrewName: String,
        zmanTime: Date
    ) -> PrayerMilestone {
        if minutes > 30 {
            return PrayerMilestone(
                name: "\(prayerName) begins in \(minutes) minutes",
                hebrewName: "\(hebrewName) מתחיל בעוד \(minutes) דקות",
                time: zmanTime,
                halachicDescription: "Best preparation time before prayer"
            )
        } else if minutes > 15 {
            return PrayerMilestone(
                name: "\(prayerName) in ~30 minutes",
                hebrewName: "\(hebrewName) בעוד כ-30 דקות",
                time: zmanTime,
                halachicDescription: "Time to prepare for prayer"
            )
        } else if minutes > 5 {
            return PrayerMilestone(
                name: "\(prayerName) in ~15 minutes",
                hebrewName: "\(hebrewName) בעוד כ-15 דקות",
                time: zmanTime,
                halachicDescription: "Soon - prepare for prayer"
            )
        } else if minutes > 1 {
            return PrayerMilestone(
                name: "\(prayerName) starting soon",
                hebrewName: "\(hebrewName) מתחיל בקרוב",
                time: zmanTime,
                halachicDescription: "Get ready now"
            )
        } else {
            return PrayerMilestone(
                name: "\(prayerName) starts now",
                hebrewName: "\(hebrewName) מתחיל עכשיו",
                time: zmanTime,
                halachicDescription: "Time to pray"
            )
        }
    }
    
    /// Find a zman by ID in the list.
    private func findZman(_ zmanim: [ZmanTime], id: String) -> ZmanTime? {
        zmanim.first { $0.id == id }
    }
    
    deinit {
        stopMonitoring()
    }
}

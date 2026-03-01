import Foundation

private func localizedRuntimeValue(_ key: String, fallback: String) -> String {
    let value = NSLocalizedString(key, comment: "")
    return value == key ? fallback : value
}

/// Represents the state of the next prayer to be observed.
///
/// This struct tracks which prayer is upcoming and provides information about
/// the current milestone within the prayer timeline. It updates at milestone
/// boundaries (not every second) for efficiency.
struct NextPrayerState: Equatable, Sendable {
    /// The prayer that is currently active or next to be recited
    let prayer: PrayerType?
    
    /// The current milestone for the prayer timing (e.g., "Now", "In 30 min", etc.)
    let currentMilestone: PrayerMilestone
    
    /// Whether we're in a transitional period between prayers
    let isTransitional: Bool
    
    /// An alternative prayer option that might be relevant (e.g., Arvit during Shkia->Tzet window)
    let alternativePrayer: PrayerType?
    
    static let empty = NextPrayerState(
        prayer: nil,
        currentMilestone: PrayerMilestone.empty,
        isTransitional: false,
        alternativePrayer: nil
    )
}

/// Represents a milestone in the prayer timeline (e.g., "30 minutes until Shacharit").
///
/// Each prayer has multiple time windows (9 total from spec). This struct represents
/// a single milestone within that window, with halachic context and display text.
struct PrayerMilestone: Equatable, Sendable {
    let labelKey: String?
    /// Display name of the milestone (e.g., "Now", "In 30 min", "Too late")
    let name: String
    
    /// The zman (time) at which this milestone begins or is calculated
    let time: Date?

    init(
        labelKey: String? = nil,
        name: String,
        time: Date?
    ) {
        self.labelKey = labelKey
        self.name = name
        self.time = time
    }
    
    static let empty = PrayerMilestone(
        name: "Loading",
        time: nil
    )

    var displayName: String {
        if let labelKey {
            let localizedByKey = localizedRuntimeValue(labelKey, fallback: labelKey)
            if localizedByKey != labelKey {
                return localizedByKey
            }
        }

        let localizedByName = localizedRuntimeValue(name, fallback: name)
        if localizedByName != name {
            return localizedByName
        }

        return name
    }
}

/// Suggested prayer for the "Suggested For You" section of the home screen.
///
/// These are contextually relevant prayers based on the current date and time,
/// such as Havdala on Saturday night or Omer counting during Sefirah.
struct SuggestedItem: Identifiable, Equatable, Sendable {
    let id: String
    
    /// SF Symbol icon name for the suggested prayer
    let icon: String
    
    /// Display title of the suggested prayer (e.g., "Havdala")
    let title: String
    
    /// The prayer type this suggestion represents
    let prayerType: PrayerType
    
    /// Optional badge text (e.g., "Tonight", "Day 5", "Chanukah night 3")
    let badgeText: String?
    
    /// Hebrew display name for the prayer (used in RTL layout)
    let hebrewTitle: String
    
    /// Brief halachic description explaining why this is suggested
    let description: String
    
    init(
        icon: String,
        title: String,
        hebrewTitle: String,
        prayerType: PrayerType,
        badgeText: String? = nil,
        description: String = ""
    ) {
        self.id = "\(prayerType.rawValue)-\(badgeText ?? "")"
        self.icon = icon
        self.title = title
        self.hebrewTitle = hebrewTitle
        self.prayerType = prayerType
        self.badgeText = badgeText
        self.description = description
    }
}

/// Represents a special zman (time) relevant to the current day.
///
/// These are special times like Shkia (sunset) or Tzet HaKochavim (nightfall)
/// that mark prayer opportunities or transitions.
struct SpecialZman: Equatable, Sendable {
    let labelKey: String?
    /// Name of the zman (e.g., "Sunset", "Nightfall")
    let name: String
    
    /// Hebrew name of the zman (e.g., "שקיעה", "צאת הכוכבים")
    let hebrewName: String
    
    /// The time this zman occurs
    let time: Date?
    
    /// Context explaining the significance of this zman
    /// (e.g., "Arvit can be said after Shkia until Tzet HaKochavim")
    let context: String

    init(
        labelKey: String? = nil,
        name: String,
        hebrewName: String,
        time: Date?,
        context: String
    ) {
        self.labelKey = labelKey
        self.name = name
        self.hebrewName = hebrewName
        self.time = time
        self.context = context
    }

    var displayName: String {
        if let labelKey {
            let localizedByKey = localizedRuntimeValue(labelKey, fallback: labelKey)
            if localizedByKey != labelKey {
                return localizedByKey
            }
        }

        let localizedByName = localizedRuntimeValue(name, fallback: name)
        if localizedByName != name {
            return localizedByName
        }

        return RuntimeLocale.isHebrew ? hebrewName : name
    }
}

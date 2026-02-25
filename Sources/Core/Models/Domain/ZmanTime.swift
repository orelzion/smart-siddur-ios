import Foundation

enum RuntimeLocale {
    static var activeLanguageCode: String {
        let appPreferred = Bundle.main.preferredLocalizations.first?.lowercased()
        let systemPreferred = Locale.preferredLanguages.first?.lowercased()
        return appPreferred ?? systemPreferred ?? "en"
    }

    static var preferredLanguageCode: String {
        activeLanguageCode
    }

    static var isHebrew: Bool {
        preferredLanguageCode.hasPrefix("he") || preferredLanguageCode.hasPrefix("iw")
    }
}

enum LocaleFormatters {
    static func longDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = .autoupdatingCurrent
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }

    static func dayMonthYear(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = .autoupdatingCurrent
        formatter.setLocalizedDateFormatFromTemplate("d MMMM y")
        return formatter.string(from: date)
    }

    static func monthYear(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = .autoupdatingCurrent
        formatter.setLocalizedDateFormatFromTemplate("MMMM y")
        return formatter.string(from: date)
    }

    static func time(_ date: Date, use24h: Bool, timeZone: TimeZone = .autoupdatingCurrent) -> String {
        let formatter = DateFormatter()
        formatter.locale = .autoupdatingCurrent
        formatter.timeZone = timeZone
        formatter.dateFormat = DateFormatter.dateFormat(
            fromTemplate: use24h ? "HH:mm" : "h:mm a",
            options: 0,
            locale: .autoupdatingCurrent
        )
        return formatter.string(from: date)
    }

    static func shortTime(_ date: Date, use24h: Bool) -> String {
        time(date, use24h: use24h, timeZone: .autoupdatingCurrent)
    }
}

// MARK: - ZmanCategory

enum ZmanCategory: String, Sendable {
    case dawn
    case morning
    case midday
    case afternoon
    case evening
    case night
    case shabbat
}

// MARK: - ZmanTime

/// Represents a single halachic time (zman) entry.
struct ZmanTime: Identifiable, Sendable {
    let id: String
    let labelKey: String?
    let name: String
    let time: Date?
    let category: ZmanCategory
    let isEssential: Bool
    var isNextUpcoming: Bool = false

    init(
        id: String,
        labelKey: String? = nil,
        name: String,
        time: Date?,
        category: ZmanCategory,
        isEssential: Bool,
        isNextUpcoming: Bool = false
    ) {
        self.id = id
        self.labelKey = labelKey
        self.name = name
        self.time = time
        self.category = category
        self.isEssential = isEssential
        self.isNextUpcoming = isNextUpcoming
    }

    var primaryLabel: String {
        if let labelKey {
            let localizedByKey = NSLocalizedString(labelKey, comment: "")
            if localizedByKey != labelKey {
                return localizedByKey
            }
        }

        let localizedByName = NSLocalizedString(name, comment: "")
        if localizedByName != name {
            return localizedByName
        }

        return name
    }

    /// Formatted time string for display.
    func formattedTime(use24h: Bool, timeZone: TimeZone) -> String {
        guard let time else { return "--:--" }
        return LocaleFormatters.time(time, use24h: use24h, timeZone: timeZone)
    }
}

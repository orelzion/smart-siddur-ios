import Foundation

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
    let name: String
    let hebrewName: String
    let time: Date?
    let category: ZmanCategory
    let isEssential: Bool
    var isNextUpcoming: Bool = false

    /// Formatted time string for display.
    func formattedTime(use24h: Bool, timeZone: TimeZone) -> String {
        guard let time else { return "--:--" }
        let formatter = DateFormatter()
        formatter.timeZone = timeZone
        if use24h {
            formatter.dateFormat = "HH:mm"
        } else {
            formatter.dateFormat = "h:mm a"
        }
        return formatter.string(from: time)
    }
}

import Foundation

// MARK: - DayType

/// Type of Jewish calendar day, used for calendar cell coloring.
enum DayType: String, Sendable {
    case regular
    case shabbat
    case yomTov
    case cholHamoed
    case fastDay
    case roshChodesh
}

// MARK: - JewishDay

/// Represents a single day's Jewish calendar information.
struct JewishDay: Identifiable, Sendable {
    let gregorianDate: Date
    let hebrewDay: Int
    let hebrewMonth: Int
    let hebrewYear: Int
    let hebrewDateString: String
    let parsha: String?
    let holiday: String?
    let isShabbat: Bool
    let isYomTov: Bool
    let isCholHamoed: Bool
    let isRoshChodesh: Bool
    let isTaanis: Bool
    let omerDay: Int?
    let dafYomi: String?
    let dayType: DayType
    let yomTovIndex: Int
    let isChanukah: Bool
    
    var id: Date { gregorianDate }
}

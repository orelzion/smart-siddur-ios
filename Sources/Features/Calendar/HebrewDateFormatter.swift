import Foundation

/// Utility for formatting Hebrew dates with gematria and Hebrew month names.
/// Handles day numbers, month names (including Adar I/II), and year formatting.
enum HebrewDateFormatterUtil {

    // MARK: - Hebrew Month Names

    /// Base Hebrew month names.
    /// NOTE: In Swift's Hebrew calendar (used by KosherSwift), Adar in a non-leap year
    /// returns month 7 (ADAR_II), not month 6 (ADAR). Month 6 is only used in leap years.
    /// The hebrewMonthName() function handles this mapping correctly.
    private static let hebrewMonthNames: [Int: String] = [
        1: "\u{05EA}\u{05E9}\u{05E8}\u{05D9}",      // Tishrei
        2: "\u{05D7}\u{05E9}\u{05D5}\u{05DF}",       // Cheshvan
        3: "\u{05DB}\u{05E1}\u{05DC}\u{05D5}",       // Kislev
        4: "\u{05D8}\u{05D1}\u{05EA}",                // Tevet
        5: "\u{05E9}\u{05D1}\u{05D8}",                // Shevat
        6: "\u{05D0}\u{05D3}\u{05E8}",                // Adar (only used in leap years as Adar I base)
        7: "\u{05D0}\u{05D3}\u{05E8}",                // Adar (non-leap: plain Adar)
        8: "\u{05E0}\u{05D9}\u{05E1}\u{05DF}",       // Nissan
        9: "\u{05D0}\u{05D9}\u{05D9}\u{05E8}",       // Iyar
        10: "\u{05E1}\u{05D9}\u{05D5}\u{05DF}",      // Sivan
        11: "\u{05EA}\u{05DE}\u{05D5}\u{05D6}",      // Tammuz
        12: "\u{05D0}\u{05D1}",                       // Av
        13: "\u{05D0}\u{05DC}\u{05D5}\u{05DC}",      // Elul
    ]

    /// In a leap year, month 6 is Adar I and month 7 is Adar II.
    private static let leapYearMonthNames: [Int: String] = [
        6: "\u{05D0}\u{05D3}\u{05E8} \u{05D0}'",     // Adar I
        7: "\u{05D0}\u{05D3}\u{05E8} \u{05D1}'",     // Adar II
    ]

    /// Base English month names.
    /// Same note as Hebrew: month 7 = plain Adar in non-leap years.
    static let englishMonthNames: [Int: String] = [
        1: "Tishrei",
        2: "Cheshvan",
        3: "Kislev",
        4: "Tevet",
        5: "Shevat",
        6: "Adar",
        7: "Adar",
        8: "Nissan",
        9: "Iyar",
        10: "Sivan",
        11: "Tammuz",
        12: "Av",
        13: "Elul",
    ]

    static let leapYearEnglishMonthNames: [Int: String] = [
        6: "Adar I",
        7: "Adar II",
    ]

    // MARK: - Gematria (Hebrew Numerals)

    /// Hebrew letters used for gematria.
    private static let onesLetters = [
        "", "\u{05D0}", "\u{05D1}", "\u{05D2}", "\u{05D3}",
        "\u{05D4}", "\u{05D5}", "\u{05D6}", "\u{05D7}", "\u{05D8}",
    ]

    private static let tensLetters = [
        "", "\u{05D9}", "\u{05DB}", "\u{05DC}", "\u{05DE}",
        "\u{05E0}", "\u{05E1}", "\u{05E2}", "\u{05E4}", "\u{05E6}",
    ]

    private static let hundredsLetters = [
        "", "\u{05E7}", "\u{05E8}", "\u{05E9}", "\u{05EA}",
        "\u{05EA}\u{05E7}", "\u{05EA}\u{05E8}", "\u{05EA}\u{05E9}", "\u{05EA}\u{05EA}",
        "\u{05EA}\u{05EA}\u{05E7}",
    ]

    /// Convert a number to Hebrew gematria string (1-999).
    static func gematria(_ number: Int) -> String {
        guard number > 0 && number < 1000 else { return "\(number)" }

        let hundreds = number / 100
        let tens = (number % 100) / 10
        let ones = number % 10

        // Special cases: 15 and 16 are Tet-Vav and Tet-Zayin (not Yud-Hey or Yud-Vav)
        if tens == 1 && ones == 5 {
            return hundredsLetters[hundreds] + "\u{05D8}\"\u{05D5}"
        }
        if tens == 1 && ones == 6 {
            return hundredsLetters[hundreds] + "\u{05D8}\"\u{05D6}"
        }

        var result = hundredsLetters[hundreds] + tensLetters[tens] + onesLetters[ones]

        // Add gershayim (double quote) before last letter, or geresh (single quote) if single letter
        if result.count == 1 {
            result += "'"
        } else if result.count > 1 {
            let index = result.index(result.endIndex, offsetBy: -1)
            result.insert("\"", at: index)
        }

        return result
    }

    /// Format a Hebrew day number as gematria.
    static func hebrewDayString(_ day: Int) -> String {
        gematria(day)
    }

    /// Get Hebrew month name for a given month number, accounting for leap years.
    static func hebrewMonthName(month: Int, isLeapYear: Bool) -> String {
        if isLeapYear, let name = leapYearMonthNames[month] {
            return name
        }
        return hebrewMonthNames[month] ?? ""
    }

    /// Get English month name for a given month number.
    static func englishMonthName(month: Int, isLeapYear: Bool) -> String {
        if isLeapYear, let name = leapYearEnglishMonthNames[month] {
            return name
        }
        return englishMonthNames[month] ?? ""
    }

    /// Format Hebrew year as gematria of last 3 digits (e.g., 5786 -> 786 in gematria with quotes).
    static func hebrewYearString(_ year: Int) -> String {
        let last3 = year % 1000
        return gematria(last3)
    }

    /// Full Hebrew date string: day month year (e.g., "י\"ב שבט תשפ\"ו").
    static func fullHebrewDate(day: Int, month: Int, year: Int, isLeapYear: Bool) -> String {
        let dayStr = hebrewDayString(day)
        let monthStr = hebrewMonthName(month: month, isLeapYear: isLeapYear)
        let yearStr = hebrewYearString(year)
        return "\(dayStr) \(monthStr) \(yearStr)"
    }
}

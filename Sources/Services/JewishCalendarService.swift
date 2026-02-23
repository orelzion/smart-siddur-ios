import Foundation
import KosherSwift

/// Wraps KosherSwift JewishCalendar for Jewish calendar state:
/// holidays, parsha, omer, special days, Hebrew dates, and Daf Yomi.
struct JewishCalendarService: Sendable {

    // MARK: - Public API

    /// Get full Jewish calendar info for a given Gregorian date.
    func getJewishDay(for date: Date, isInIsrael: Bool) -> JewishDay {
        let jCal = JewishCalendar(workingDate: date)
        jCal.setInIsrael(inIsrael: isInIsrael)

        let hebrewDay = jCal.getJewishDayOfMonth()
        let hebrewMonth = jCal.getJewishMonth()
        let hebrewYear = jCal.getJewishYear()

        // Hebrew date string
        let formatter = KosherSwift.HebrewDateFormatter()
        formatter.setHebrewFormat(hebrewFormat: true)
        let hebrewDateStr = formatter.format(jewishCalendar: jCal)

        // Parsha (Shabbat only)
        let parsha: String?
        let dayOfWeek = Calendar(identifier: .gregorian).component(.weekday, from: date)
        if dayOfWeek == 7 { // Saturday
            let parshaEnum = jCal.getParshah()
            if parshaEnum != .NONE {
                let parshaFormatter = KosherSwift.HebrewDateFormatter()
                parshaFormatter.setHebrewFormat(hebrewFormat: true)
                parsha = parshaFormatter.formatParsha(parsha: parshaEnum)
            } else {
                parsha = nil
            }
        } else {
            parsha = nil
        }

        // Holiday
        let holiday: String?
        let yomTovIndex = jCal.getYomTovIndex()
        if yomTovIndex > 0 {
            let holidayFormatter = KosherSwift.HebrewDateFormatter()
            let formatted = holidayFormatter.formatYomTov(jewishCalendar: jCal)
            holiday = formatted.isEmpty ? nil : formatted
        } else {
            holiday = nil
        }
        
        // Chanukah
        let isChanukah = jCal.isChanukah()

        // Day state
        let isShabbat = dayOfWeek == 7
        let isYomTov = jCal.isYomTov()
        let isCholHamoed = jCal.isCholHamoed()
        let isRoshChodesh = jCal.isRoshChodesh()
        let isTaanis = jCal.isTaanis()

        // Omer
        let omerRaw = jCal.getDayOfOmer()
        let omerDay: Int? = omerRaw > 0 ? omerRaw : nil

        // Daf Yomi
        let dafYomi: String?
        if let daf = jCal.getDafYomiBavli() {
            let dafFormatter = KosherSwift.HebrewDateFormatter()
            dafYomi = dafFormatter.formatDafYomiBavli(daf: daf)
        } else {
            dafYomi = nil
        }

        // Day type for calendar coloring
        let dayType: DayType
        if isShabbat {
            dayType = .shabbat
        } else if isYomTov {
            dayType = .yomTov
        } else if isCholHamoed {
            dayType = .cholHamoed
        } else if isTaanis {
            dayType = .fastDay
        } else if isRoshChodesh {
            dayType = .roshChodesh
        } else {
            dayType = .regular
        }

        return JewishDay(
            gregorianDate: date,
            hebrewDay: hebrewDay,
            hebrewMonth: hebrewMonth,
            hebrewYear: hebrewYear,
            hebrewDateString: hebrewDateStr,
            parsha: parsha,
            holiday: holiday,
            isShabbat: isShabbat,
            isYomTov: isYomTov,
            isCholHamoed: isCholHamoed,
            isRoshChodesh: isRoshChodesh,
            isTaanis: isTaanis,
            omerDay: omerDay,
            dafYomi: dafYomi,
            dayType: dayType,
            yomTovIndex: yomTovIndex,
            isChanukah: isChanukah
        )
    }

    /// Get JewishDay entries for every day in a given Gregorian month.
    func getJewishDaysForMonth(year: Int, month: Int, isInIsrael: Bool) -> [JewishDay] {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .current

        guard let startDate = calendar.date(from: DateComponents(year: year, month: month, day: 1)),
              let range = calendar.range(of: .day, in: .month, for: startDate) else {
            return []
        }

        return range.compactMap { day in
            guard let date = calendar.date(from: DateComponents(year: year, month: month, day: day)) else {
                return nil
            }
            return getJewishDay(for: date, isInIsrael: isInIsrael)
        }
    }

    /// Get JewishDay entries for one full Hebrew month containing the provided date.
    func getJewishDaysForHebrewMonth(containing date: Date, isInIsrael: Bool) -> [JewishDay] {
        let cal = Calendar(identifier: .gregorian)
        var cursor = date
        var current = getJewishDay(for: cursor, isInIsrael: isInIsrael)

        while current.hebrewDay > 1 {
            guard let prev = cal.date(byAdding: .day, value: -1, to: cursor) else { break }
            cursor = prev
            current = getJewishDay(for: cursor, isInIsrael: isInIsrael)
        }

        let targetMonth = current.hebrewMonth
        let targetYear = current.hebrewYear
        var result: [JewishDay] = []
        var iterDate = cursor

        while true {
            let day = getJewishDay(for: iterDate, isInIsrael: isInIsrael)
            guard day.hebrewMonth == targetMonth && day.hebrewYear == targetYear else { break }
            result.append(day)
            guard let next = cal.date(byAdding: .day, value: 1, to: iterDate) else { break }
            iterDate = next
        }

        return result
    }

    /// Format "Rosh Chodesh <Month>" using KosherSwift's native formatter.
    func roshChodeshName(for date: Date, isInIsrael: Bool, hebrewFormat: Bool = false) -> String? {
        let jCal = JewishCalendar(workingDate: date)
        jCal.setInIsrael(inIsrael: isInIsrael)
        let formatter = KosherSwift.HebrewDateFormatter()
        formatter.setHebrewFormat(hebrewFormat: hebrewFormat)
        let text = formatter.formatRoshChodesh(jewishCalendar: jCal)
        return text.isEmpty ? nil : text
    }

    /// Shabbos Mevorchim status from KosherSwift.
    func isShabbosMevorchim(for date: Date, isInIsrael: Bool) -> Bool {
        let jCal = JewishCalendar(workingDate: date)
        jCal.setInIsrael(inIsrael: isInIsrael)
        return jCal.isShabbosMevorchim()
    }

    /// Molad for the upcoming Hebrew month in Yerushalayim standard time.
    func upcomingMonthMoladDate(from date: Date, isInIsrael: Bool) -> Date? {
        let cal = Calendar(identifier: .gregorian)
        var cursor = date

        for _ in 0..<40 {
            let day = JewishCalendar(workingDate: cursor)
            day.setInIsrael(inIsrael: isInIsrael)
            if day.getJewishDayOfMonth() == 1 && day.getJewishMonth() != JewishCalendar.TISHREI {
                return day.getMoladAsDate()
            }
            guard let next = cal.date(byAdding: .day, value: 1, to: cursor) else { break }
            cursor = next
        }
        return nil
    }

    /// Traditional Hebrew molad format, based on KosherSwift's internal molad chalakim math.
    /// Example: "יום שלישי, שעה שישית ו־280 חלקים"
    func upcomingMonthMoladTraditionalHebrew(from date: Date, isInIsrael: Bool) -> String? {
        let cal = Calendar(identifier: .gregorian)
        var cursor = date

        for _ in 0..<40 {
            let day = JewishCalendar(workingDate: cursor)
            day.setInIsrael(inIsrael: isInIsrael)
            if day.getJewishDayOfMonth() == 1 && day.getJewishMonth() != JewishCalendar.TISHREI {
                let moladChalakim = day.getChalakimSinceMoladTohu()
                return formatMoladTraditionalHebrew(moladChalakim: moladChalakim)
            }
            guard let next = cal.date(byAdding: .day, value: 1, to: cursor) else { break }
            cursor = next
        }
        return nil
    }

    private func formatMoladTraditionalHebrew(moladChalakim: Int64) -> String {
        let chalakimPerHour: Int64 = 1080
        let chalakimPerDay: Int64 = 24 * chalakimPerHour

        var adjusted = moladChalakim
        var days = adjusted / chalakimPerDay
        adjusted -= days * chalakimPerDay

        let hours = adjusted / chalakimPerHour
        if hours >= 6 {
            days += 1
        }

        let partsWithinHour = adjusted - (hours * chalakimPerHour)

        let dayName = weekdayHebrewName(for: Int(days % 7))
        let hourHebrew = hebrewOrdinalHour(Int(hours))
        return "יום \(dayName), שעה \(hourHebrew) ו-\(partsWithinHour) חלקים"
    }

    private func weekdayHebrewName(for day: Int) -> String {
        switch day {
        case 1: return "ראשון"
        case 2: return "שני"
        case 3: return "שלישי"
        case 4: return "רביעי"
        case 5: return "חמישי"
        case 6: return "שישי"
        default: return "שבת"
        }
    }

    private func hebrewOrdinalHour(_ hour: Int) -> String {
        let mapping: [Int: String] = [
            0: "ראשונה", 1: "שנייה", 2: "שלישית", 3: "רביעית", 4: "חמישית", 5: "שישית",
            6: "שביעית", 7: "שמינית", 8: "תשיעית", 9: "עשירית", 10: "אחת עשרה", 11: "שתים עשרה",
            12: "שלוש עשרה", 13: "ארבע עשרה", 14: "חמש עשרה", 15: "שש עשרה", 16: "שבע עשרה",
            17: "שמונה עשרה", 18: "תשע עשרה", 19: "עשרים", 20: "עשרים ואחת", 21: "עשרים ושתיים",
            22: "עשרים ושלוש", 23: "עשרים וארבע"
        ]
        return mapping[hour] ?? "\(hour)"
    }
    
    /// Get seasonal badge text for display on home screen
    func seasonalBadge(for date: Date) -> String? {
        let jCal = JewishCalendar(workingDate: date)
        let hebrewMonth = jCal.getJewishMonth()
        let hebrewDay = jCal.getJewishDayOfMonth()
        
        // Chanukah
        if jCal.isChanukah() {
            let night = jCal.getDayOfChanukah()
            return "🕯️ Chanukah night \(night)"
        }
        
        // Omer
        let omer = jCal.getDayOfOmer()
        if omer > 0 {
            return "📊 Sefirat HaOmer night \(omer)"
        }
        
        // Rosh Chodesh Nisan
        if hebrewMonth == 7 && jCal.isRoshChodesh() {
            return "🌳 Birkat Ha'Ilanot available"
        }
        
        return nil
    }
}

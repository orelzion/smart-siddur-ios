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

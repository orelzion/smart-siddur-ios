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

    /// Get a seasonal badge string for a given Jewish day.
    ///
    /// Returns contextual text like "Birkat Ha'Ilanot available" or "Chanukah night 3".
    /// Used to display seasonal context on the home screen.
    func seasonalBadge(for jewishDay: JewishDay) -> String? {
        let hebrewMonth = jewishDay.hebrewMonth
        let hebrewDay = jewishDay.hebrewDay
        let yomTovIndex = jewishDay.yomTovIndex
        let omerDay = jewishDay.omerDay
        
        // NISAN - Birkat Ha'Ilanot season
        if hebrewMonth == JewishCalendar.NISSAN {
            return "🌳 Birkat Ha'Ilanot available"
        }
        
        // SEFIRAT HA'OMER - show night number
        if let omerDay = omerDay {
            let weekNumber = (omerDay - 1) / 7 + 1
            let dayInWeek = (omerDay - 1) % 7 + 1
            
            if omerDay <= 7 {
                return "📊 Sefirat HaOmer night \(omerDay)"
            } else {
                return "📊 Omer night \(weekNumber):\(dayInWeek)"
            }
        }
        
        // CHANUKAH
        if jewishDay.isChanukah {
            let chanukahNight = max(1, hebrewDay - 24)
            return "🕯️ Chanukah night \(chanukahNight)"
        }
        
        // ROSH CHODESH - any month
        if jewishDay.isRoshChodesh {
            let monthName = hebrewMonthName(hebrewMonth)
            return "🌙 Rosh Chodesh \(monthName)"
        }
        
        // FAST DAYS (other than Yom Kippur which is Yom Tov)
        if jewishDay.isTaanis && yomTovIndex != JewishCalendar.YOM_KIPPUR {
            if yomTovIndex == JewishCalendar.TISHA_BEAV {
                return "⚫ Tisha B'Av"
            } else if yomTovIndex == JewishCalendar.FAST_OF_GEDALIAH {
                return "⚫ Fast of Gedaliah"
            } else if yomTovIndex == JewishCalendar.FAST_OF_ESTHER {
                return "⚫ Fast of Esther"
            } else if yomTovIndex == JewishCalendar.FAST_OF_17_TAMMUZ {
                return "⚫ 17 Tammuz Fast"
            }
        }
        
        // LAG BA'OMER
        if yomTovIndex == JewishCalendar.LAG_BAOMER {
            return "🔥 Lag Ba'Omer"
        }
        
        // PURIM
        if yomTovIndex == JewishCalendar.PURIM {
            return "🎭 Purim"
        }
        
        // PESACH
        if yomTovIndex >= JewishCalendar.PESACH && yomTovIndex <= JewishCalendar.CHOL_HAMOED_PESACH {
            return "🫓 Pesach"
        }
        
        // SHAVUOT
        if yomTovIndex >= JewishCalendar.SHAVUOT && yomTovIndex <= JewishCalendar.SHAVUOT2 {
            return "📖 Shavuot"
        }
        
        // ROSH HASHANA
        if yomTovIndex >= JewishCalendar.ROSH_HASHANA && yomTovIndex <= JewishCalendar.ROSH_HASHANA2 {
            return "🍎 Rosh Hashana"
        }
        
        // YOM KIPPUR
        if yomTovIndex == JewishCalendar.YOM_KIPPUR {
            return "⚪ Yom Kippur"
        }
        
        // SUKKOT
        if yomTovIndex >= JewishCalendar.SUCCOS && yomTovIndex <= JewishCalendar.CHOL_HAMOED_SUCCOS {
            return "🏕️ Sukkot"
        }
        
        // SIMCHAT TORAH
        if yomTovIndex == JewishCalendar.SIMCHAT_TORAH || yomTovIndex == JewishCalendar.SHEMINI_ATZERET {
            return "🎉 Simchat Torah"
        }
        
        // No seasonal badge
        return nil
    }
    
    /// Get Hebrew month name for the month number.
    private func hebrewMonthName(_ month: Int) -> String {
        switch month {
        case JewishCalendar.TISHREI: return "Tishrei"
        case JewishCalendar.CHESHVAN: return "Cheshvan"
        case JewishCalendar.KISLEV: return "Kislev"
        case JewishCalendar.TEVET: return "Tevet"
        case JewishCalendar.SHEVAT: return "Shevat"
        case JewishCalendar.ADAR: return "Adar"
        case JewishCalendar.ADAR_II: return "Adar II"
        case JewishCalendar.NISSAN: return "Nisan"
        case JewishCalendar.IYAR: return "Iyar"
        case JewishCalendar.SIVAN: return "Sivan"
        case JewishCalendar.TAMMUZ: return "Tammuz"
        case JewishCalendar.AV: return "Av"
        case JewishCalendar.ELUL: return "Elul"
        default: return "Month \(month)"
        }
    }
}

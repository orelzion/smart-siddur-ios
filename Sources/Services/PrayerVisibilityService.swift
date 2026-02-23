import Foundation
import KosherSwift

struct PrayerVisibilityContext: Sendable {
    let jewishDay: JewishDay
    let nusach: Nusach
    let isMotzaeiShabbat: Bool
    let isLevanaAvailable: Bool
    let isAfterPlagOnErevChanukah: Bool
    
    static let empty = PrayerVisibilityContext(
        jewishDay: JewishDay(
            gregorianDate: Date(),
            hebrewDay: 1,
            hebrewMonth: 1,
            hebrewYear: 5784,
            hebrewDateString: "",
            parsha: nil,
            holiday: nil,
            isShabbat: false,
            isYomTov: false,
            isCholHamoed: false,
            isRoshChodesh: false,
            isTaanis: false,
            omerDay: nil,
            dafYomi: nil,
            dayType: .regular,
            yomTovIndex: -1,
            isChanukah: false
        ),
        nusach: .edot,
        isMotzaeiShabbat: false,
        isLevanaAvailable: false,
        isAfterPlagOnErevChanukah: false
    )
}

struct PrayerVisibilityService: Sendable {
    
    func visiblePrayers(in context: PrayerVisibilityContext) -> Set<PrayerType> {
        var visible: Set<PrayerType> = []
        
        let jewishDay = context.jewishDay
        let yomTovIndex = jewishDay.yomTovIndex
        let hebrewMonth = jewishDay.hebrewMonth
        
        // Omer - shown during Omer period (between Pesach and Shavuot)
        if jewishDay.omerDay != nil {
            visible.insert(.omer)
        }
        
        // Ushpizin - shown during Chol HaMoed Succos or Hoshana Rabba, but NOT for Chabad
        let isSuccot = yomTovIndex == JewishCalendar.CHOL_HAMOED_SUCCOS || yomTovIndex == JewishCalendar.HOSHANA_RABBA
        if isSuccot && context.nusach != .chabad {
            visible.insert(.ushpizin)
        }
        
        // Lag Baomer
        if yomTovIndex == JewishCalendar.LAG_BAOMER {
            visible.insert(.lagBaomer)
        }
        
        // Levana - Birkat HaLevana can be said when it's visible
        if context.isLevanaAvailable {
            visible.insert(.levana)
        }
        
        // Havdala - shown on Motzaei Shabbat (after Shabbat ends)
        if context.isMotzaeiShabbat {
            visible.insert(.havdala)
        }
        
        // Chanukah - shown during Chanukah OR on Erev Chanukah after Plag HaMincha
        if jewishDay.isChanukah || context.isAfterPlagOnErevChanukah {
            visible.insert(.hanuka)
        }
        
        // Ilanot - blessing on trees in Nisan
        if hebrewMonth == JewishCalendar.NISSAN {
            visible.insert(.ilanot)
        }
        
        // Kinot - Tisha B'Av
        if yomTovIndex == JewishCalendar.TISHA_BEAV {
            visible.insert(.kinot)
        }
        
        // Slihot - based on nusach and time of year
        if isSlihotTime(jewishDay: jewishDay, nusach: context.nusach) {
            visible.insert(.slihot)
        }
        
        // Nedarim - Erev Rosh Hashana or Erev Yom Kippur
        let isHataratNedarimTime = yomTovIndex == JewishCalendar.EREV_ROSH_HASHANA || yomTovIndex == JewishCalendar.EREV_YOM_KIPPUR
        if isHataratNedarimTime {
            visible.insert(.nedarim)
        }
        
        return visible
    }
    
    private func isSlihotTime(jewishDay: JewishDay, nusach: Nusach) -> Bool {
        let yomTovIndex = jewishDay.yomTovIndex
        let hebrewMonth = jewishDay.hebrewMonth
        let hebrewDayOfMonth = jewishDay.hebrewDay
        
        // Check if in Aseret Yemei Teshuva (1-10 Tishrei)
        let isInAseretYemeiTeshuva: Bool
        if yomTovIndex >= 9 && yomTovIndex <= 13 {
            isInAseretYemeiTeshuva = true
        } else if hebrewMonth == JewishCalendar.TISHREI && hebrewDayOfMonth >= 1 && hebrewDayOfMonth <= 10 {
            isInAseretYemeiTeshuva = true
        } else {
            isInAseretYemeiTeshuva = false
        }
        
        if isInAseretYemeiTeshuva {
            return true
        }
        
        // Elul for Edot HaMizrach / Sfarad (entire month of Elul)
        if nusach == .edot || nusach == .sfarad {
            if hebrewMonth == JewishCalendar.ELUL {
                return true
            }
        }
        
        // Ashkenaz / Chabad: from the Sunday before Rosh Hashana
        // This is typically 4 days before Rosh Hashana (when Rosh Hashana falls on Mon-Thu)
        // or 3 days when it falls on other days. Simplified: check if we're in late Elul.
        if nusach == .ashkenaz || nusach == .chabad {
            // For Ashkenazi: Selichot start from the Sunday before Rosh Hashana
            // (at least 4 days before RH). Simplify to: last week of Elul
            if hebrewMonth == JewishCalendar.ELUL && hebrewDayOfMonth >= 25 {
                return true
            }
        }
        
        return false
    }
    
    func isSpecialCategoryEmpty(context: PrayerVisibilityContext) -> Bool {
        return visiblePrayers(in: context).isEmpty
    }
}

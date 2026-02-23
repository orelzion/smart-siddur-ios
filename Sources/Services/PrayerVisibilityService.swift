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
    
    /// Generate suggested items for the "Suggested For You" section.
    ///
    /// Returns contextually relevant prayers based on the Jewish calendar and time.
    /// Always includes core items, then adds seasonal/contextual items based on the date.
    func suggestedItems(for date: Date, jewishDay: JewishDay) -> [SuggestedItem] {
        var items: [SuggestedItem] = []
        
        let yomTovIndex = jewishDay.yomTovIndex
        let hebrewMonth = jewishDay.hebrewMonth
        let omerDay = jewishDay.omerDay
        
        // ALWAYS include these core items
        items.append(SuggestedItem(
            icon: "fork.knife",
            title: "Birkat HaMazon",
            hebrewTitle: "ברכת המזון",
            prayerType: .mazon,
            badgeText: nil,
            description: "Grace after meals"
        ))
        
        items.append(SuggestedItem(
            icon: "drop",
            title: "Asher Yatzar",
            hebrewTitle: "אשר יצר",
            prayerType: .asherYatzar,
            badgeText: nil,
            description: "Blessing after using restroom"
        ))
        
        // OMER COUNTING - shown during Sefirat HaOmer period
        if let omerDay = omerDay {
            let weekNumber = (omerDay - 1) / 7 + 1
            let dayInWeek = (omerDay - 1) % 7 + 1
            
            var badgeText: String?
            if omerDay <= 7 {
                badgeText = "Tonight - Day \(omerDay)"
            } else {
                badgeText = "Night \(weekNumber):\(dayInWeek)"
            }
            
            items.append(SuggestedItem(
                icon: "number.circle",
                title: "Sefirat HaOmer",
                hebrewTitle: "ספירת העומר",
                prayerType: .omer,
                badgeText: badgeText,
                description: "Counting of the Omer"
            ))
        }
        
        // HAVDALA - Motzaei Shabbat (Saturday night)
        let dayOfWeek = Calendar(identifier: .gregorian).component(.weekday, from: date)
        if dayOfWeek == 7 { // Saturday - show Havdala suggestion for tonight
            items.append(SuggestedItem(
                icon: "candle.2",
                title: "Havdala",
                hebrewTitle: "הבדלה",
                prayerType: .havdala,
                badgeText: "Tonight",
                description: "Ceremony ending Shabbat"
            ))
        }
        
        // ARVIT QUICK ACCESS - during Shkia to Tzeit window
        // This is a navigational aid, shown with context
        items.append(SuggestedItem(
            icon: "moon.stars",
            title: "Arvit",
            hebrewTitle: "ערבית",
            prayerType: .arvit,
            badgeText: "Quick access",
            description: "Evening prayer (after sunset)"
        ))
        
        // CHANUKAH
        if jewishDay.isChanukah {
            let chanukahNight = jewishDay.hebrewDay - 24 // Chanukah starts on 25 Kislev
            items.append(SuggestedItem(
                icon: "flame",
                title: "Chanukah",
                hebrewTitle: "חנוכה",
                prayerType: .hanuka,
                badgeText: "Night \(max(1, chanukahNight))",
                description: "Chanukah prayers and blessings"
            ))
        }
        
        // ILANOT - Nisan (tree blessing season)
        if hebrewMonth == JewishCalendar.NISSAN {
            items.append(SuggestedItem(
                icon: "tree",
                title: "Birkat HaIlanot",
                hebrewTitle: "ברכת האילנות",
                prayerType: .ilanot,
                badgeText: "Nisan",
                description: "Blessing over blossoming trees"
            ))
        }
        
        // KINOT - Tisha B'Av
        if yomTovIndex == JewishCalendar.TISHA_BEAV {
            items.append(SuggestedItem(
                icon: "building.columns",
                title: "Kinot",
                hebrewTitle: "קינות",
                prayerType: .kinot,
                badgeText: "Tisha B'Av",
                description: "Lamentations for Tisha B'Av"
            ))
        }
        
        // SELICHOT - High Holiday season
        if isSlihotTime(jewishDay: jewishDay, nusach: .edot) {
            items.append(SuggestedItem(
                icon: "horn",
                title: "Selichot",
                hebrewTitle: "סליחות",
                prayerType: .slihot,
                badgeText: "High Holidays",
                description: "Penitential prayers"
            ))
        }
        
        // LEVANA - Birkat HaLevana (moon visible, appropriate time)
        // This would be more sophisticated in production with actual moon calculations
        if yomTovIndex != JewishCalendar.YOM_KIPPUR {
            // Don't show during Yom Kippur
            items.append(SuggestedItem(
                icon: "moon.circle",
                title: "Birkat HaLevana",
                hebrewTitle: "ברכת הלבנה",
                prayerType: .levana,
                badgeText: "When visible",
                description: "Blessing of the new moon"
            ))
        }
        
        return items
    }
}

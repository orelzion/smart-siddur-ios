import Foundation
import KosherSwift

// MARK: - ZmanimOpinions

/// Aggregated opinion preferences for zmanim calculation.
struct ZmanimOpinions: Sendable {
    let dawnOpinion: DawnOpinion
    let sunriseOpinion: SunriseOpinion
    let zmanOpinion: ZmanOpinion
    let duskOpinion: DuskOpinion
    let shabbatCandleMinutes: Int
    let shabbatEndMinutes: Int

    static let defaults = ZmanimOpinions(
        dawnOpinion: .alot72,
        sunriseOpinion: .seaLevel,
        zmanOpinion: .gra,
        duskOpinion: .baalHatania,
        shabbatCandleMinutes: 20,
        shabbatEndMinutes: 1
    )
}

// MARK: - ZmanimService

/// Wraps KosherSwift with opinion-aware zmanim calculation.
/// Creates a ComplexZmanimCalendar for the user's location and date,
/// then maps opinion settings to the correct KosherSwift methods.
struct ZmanimService: Sendable {

    // MARK: - Public API

    /// Calculate all zmanim for the given date, location, and user opinions.
    /// Returns both essential (~8-10) and comprehensive (~15-20) zmanim,
    /// plus separate Shabbat times (candle lighting, havdalah) when applicable.
    func calculateZmanim(
        date: Date,
        location: UserLocation,
        opinions: ZmanimOpinions
    ) -> [ZmanTime] {
        let calendar = makeCalendar(date: date, location: location, opinions: opinions)
        var zmanim: [ZmanTime] = []

        // -- Essential zmanim (isEssential = true) --

        // 1. Dawn (Alot HaShachar)
        let alotTime = dawnTime(calendar: calendar, opinion: opinions.dawnOpinion)
        zmanim.append(ZmanTime(
            id: "alot",
            labelKey: "alotZmanTitle",
            name: "Dawn",
            time: alotTime,
            category: .dawn,
            isEssential: true
        ))

        // 2. Sunrise (Netz HaChama)
        let sunriseTime = sunrise(calendar: calendar, opinion: opinions.sunriseOpinion)
        zmanim.append(ZmanTime(
            id: "netz",
            labelKey: "zman_sunrise",
            name: "Sunrise",
            time: sunriseTime,
            category: .morning,
            isEssential: true
        ))

        // 3. Sof Zman Shma (default opinion)
        let sofShmaTime = sofZmanShma(calendar: calendar, opinion: opinions.zmanOpinion)
        let shmaLabel = opinions.zmanOpinion == .gra ? "GR\"A" : "MGA"
        let shmaLabelKey = opinions.zmanOpinion == .gra ? "zman_shma_gra" : "zman_shma_mga"
        zmanim.append(ZmanTime(
            id: "sofZmanShma",
            labelKey: shmaLabelKey,
            name: "Sof Zman Shma (\(shmaLabel))",
            time: sofShmaTime,
            category: .morning,
            isEssential: true
        ))

        // 4. Sof Zman Tfila (default opinion)
        let sofTfilaTime = sofZmanTfila(calendar: calendar, opinion: opinions.zmanOpinion)
        let tfilaLabel = opinions.zmanOpinion == .gra ? "GR\"A" : "MGA"
        let tfilaLabelKey = opinions.zmanOpinion == .gra ? "zman_tfila_gra" : "zman_tfila_mga"
        zmanim.append(ZmanTime(
            id: "sofZmanTfila",
            labelKey: tfilaLabelKey,
            name: "Sof Zman Tfila (\(tfilaLabel))",
            time: sofTfilaTime,
            category: .morning,
            isEssential: true
        ))

        // 5. Midday (Chatzot)
        zmanim.append(ZmanTime(
            id: "chatzot",
            name: "Midday",
            time: calendar.getChatzos(),
            category: .midday,
            isEssential: true
        ))

        // 6. Mincha Gedola
        zmanim.append(ZmanTime(
            id: "minchaGedola",
            labelKey: "minchaBigZmanTitle",
            name: "Mincha Gedola",
            time: calendar.getMinchaGedola(),
            category: .afternoon,
            isEssential: true
        ))

        // 7. Sunset (Shkia)
        zmanim.append(ZmanTime(
            id: "shkia",
            labelKey: "zman_sunset",
            name: "Sunset",
            time: calendar.getElevationAdjustedSunset(),
            category: .evening,
            isEssential: true
        ))

        // 8. Nightfall (Tzeit HaKochavim)
        let tzeitTime = nightfall(calendar: calendar, opinion: opinions.duskOpinion)
        zmanim.append(ZmanTime(
            id: "tzeit",
            labelKey: "zman_nightfall",
            name: "Nightfall",
            time: tzeitTime,
            category: .night,
            isEssential: true
        ))

        // -- Comprehensive additions (isEssential = false) --

        // 9. Tallit & Tefillin (Misheyakir - earliest time)
        zmanim.append(ZmanTime(
            id: "misheyakir",
            name: "Tallit & Tefillin",
            time: calendar.getMisheyakir11Point5Degrees(),
            category: .dawn,
            isEssential: false
        ))

        // 10. Sof Zman Shma (other opinion)
        let otherZmanOpinion: ZmanOpinion = opinions.zmanOpinion == .gra ? .mga : .gra
        let otherShmaLabel = otherZmanOpinion == .gra ? "GR\"A" : "MGA"
        let otherShmaKey = otherZmanOpinion == .gra ? "zman_shma_gra" : "zman_shma_mga"
        zmanim.append(ZmanTime(
            id: "sofZmanShmaAlt",
            labelKey: otherShmaKey,
            name: "Sof Zman Shma (\(otherShmaLabel))",
            time: sofZmanShma(calendar: calendar, opinion: otherZmanOpinion),
            category: .morning,
            isEssential: false
        ))

        // 11. Sof Zman Tfila (other opinion)
        let otherTfilaLabel = otherZmanOpinion == .gra ? "GR\"A" : "MGA"
        let otherTfilaKey = otherZmanOpinion == .gra ? "zman_tfila_gra" : "zman_tfila_mga"
        zmanim.append(ZmanTime(
            id: "sofZmanTfilaAlt",
            labelKey: otherTfilaKey,
            name: "Sof Zman Tfila (\(otherTfilaLabel))",
            time: sofZmanTfila(calendar: calendar, opinion: otherZmanOpinion),
            category: .morning,
            isEssential: false
        ))

        // 12. Mincha Ketana
        zmanim.append(ZmanTime(
            id: "minchaKetana",
            name: "Mincha Ketana",
            time: calendar.getMinchaKetana(),
            category: .afternoon,
            isEssential: false
        ))

        // 13. Plag HaMincha
        zmanim.append(ZmanTime(
            id: "plagHamincha",
            labelKey: "plagZmanTitle",
            name: "Plag HaMincha",
            time: calendar.getPlagHamincha(),
            category: .afternoon,
            isEssential: false
        ))

        // 14. Nightfall 72 min
        zmanim.append(ZmanTime(
            id: "tzeit72",
            name: "Nightfall 72 min",
            time: calendar.getTzais72(),
            category: .night,
            isEssential: false
        ))

        // 15. Nightfall Rabenu Tam
        zmanim.append(ZmanTime(
            id: "tzeitRabenuTam",
            name: "Nightfall Rabenu Tam",
            time: calendar.getTzais72(),
            category: .night,
            isEssential: false
        ))

        // 16. Midnight (Chatzot HaLaila)
        let midnightTime = solarMidnight(calendar: calendar)
        zmanim.append(ZmanTime(
            id: "chatzotHalaila",
            name: "Midnight",
            time: midnightTime,
            category: .night,
            isEssential: false
        ))

        return zmanim
    }

    /// Calculate candle lighting and havdalah times for Shabbat.
    /// Returns candle lighting for Friday, havdalah for Saturday night, empty otherwise.
    func shabbatTimes(
        date: Date,
        location: UserLocation,
        opinions: ZmanimOpinions
    ) -> [ZmanTime] {
        let gregorianCalendar = Calendar(identifier: .gregorian)
        let dayOfWeek = gregorianCalendar.component(.weekday, from: date)
        var result: [ZmanTime] = []

        let zmanimCalendar = makeCalendar(date: date, location: location, opinions: opinions)

        // Friday (dayOfWeek == 6): candle lighting
        if dayOfWeek == 6 {
            zmanimCalendar.setCandleLightingOffset(candleLightingOffset: opinions.shabbatCandleMinutes)
            result.append(ZmanTime(
                id: "candleLighting",
                labelKey: "shabbatEnterZmanTitle",
                name: "Candle Lighting",
                time: zmanimCalendar.getCandleLighting(),
                category: .shabbat,
                isEssential: true
            ))
        }

        // Saturday (dayOfWeek == 7): havdalah
        if dayOfWeek == 7 {
            // Havdalah = sunset + endMinutes
            let sunset = zmanimCalendar.getElevationAdjustedSunset()
            let havdalahTime = sunset.flatMap { sunsetDate in
                Calendar.current.date(byAdding: .minute, value: opinions.shabbatEndMinutes, to: sunsetDate)
            }
            result.append(ZmanTime(
                id: "havdalah",
                labelKey: "havdala_title",
                name: "Havdalah",
                time: havdalahTime,
                category: .shabbat,
                isEssential: true
            ))
        }

        return result
    }

    /// Calculate special zmanim for the given date based on Jewish calendar.
    /// Returns times like Erev Shabbat (candle lighting), Motzei Shabbat (havdala),
    /// Erev/Motzei Yom Tov, Chanukah, fast days, Pesach times, Sefirat HaOmer, etc.
    /// Empty array if no special zmanim apply to the given day.
    func specialZmanim(
        for date: Date,
        location: UserLocation,
        opinions: ZmanimOpinions,
        isInIsrael: Bool
    ) -> [SpecialZman] {
        let jCal = JewishCalendar(workingDate: date)
        jCal.setInIsrael(inIsrael: isInIsrael)
        
        let gregorianCalendar = Calendar(identifier: .gregorian)
        let dayOfWeek = gregorianCalendar.component(.weekday, from: date)
        let yomTovIndex = jCal.getYomTovIndex()
        
        var result: [SpecialZman] = []
        let zmanimCalendar = makeCalendar(date: date, location: location, opinions: opinions)
        
        // FRIDAY - Erev Shabbat: Candle Lighting
        if dayOfWeek == 6 {
            zmanimCalendar.setCandleLightingOffset(candleLightingOffset: opinions.shabbatCandleMinutes)
            if let candleTime = zmanimCalendar.getCandleLighting() {
                result.append(SpecialZman(
                    labelKey: "shabbatEnterZmanTitle",
                    name: "Erev Shabbat - Candle Lighting",
                    hebrewName: "ערב שבת - הדלקת נרות",
                    time: candleTime,
                    context: "Last time to light Shabbat candles"
                ))
            }
        }
        
        // SATURDAY - Motzei Shabbat: Havdala
        if dayOfWeek == 7 {
            if let sunset = zmanimCalendar.getElevationAdjustedSunset(),
               let havdalahTime = Calendar.current.date(byAdding: .minute, value: opinions.shabbatEndMinutes, to: sunset) {
                result.append(SpecialZman(
                    labelKey: "havdala_title",
                    name: "Motzei Shabbat - Havdala",
                    hebrewName: "מוצאי שבת - הבדלה",
                    time: havdalahTime,
                    context: "Earliest time to recite Havdala to end Shabbat"
                ))
            }
        }
        
        // CHANUKAH
        if jCal.isChanukah() {
            let hebrewDay = jCal.getJewishDayOfMonth()
            let chanukahNight = max(1, hebrewDay - 24) // Kislev 25 = night 1
            
            // Chanukah candle lighting: typically at Tzet HaKochavim
            if let tzeitTime = nightfall(calendar: zmanimCalendar, opinion: opinions.duskOpinion) {
                result.append(SpecialZman(
                    labelKey: "hanuka",
                    name: "Chanukah - Candle Lighting Night \(chanukahNight)",
                    hebrewName: "חנוכה - הדלקת נרות ליל \(chanukahNight)",
                    time: tzeitTime,
                    context: "Best time to kindle Chanukah candles (after Tzet HaKochavim)"
                ))
            }
        }
        
        // FAST DAYS
        if jCal.isTaanis() && yomTovIndex != JewishCalendar.YOM_KIPPUR {
            // Fast start: Alot HaShachar (dawn)
            if let alotTime = dawnTime(calendar: zmanimCalendar, opinion: opinions.dawnOpinion) {
                let (fastName, fastHebrewName) = fastDayNames(for: yomTovIndex, isFastBegin: true)
                
                result.append(SpecialZman(
                    name: fastName,
                    hebrewName: fastHebrewName,
                    time: alotTime,
                    context: "Fast begins at dawn (Alot HaShachar)"
                ))
            }
            
            // Fast end: Tzet HaKochavim (nightfall)
            if let tzeitTime = nightfall(calendar: zmanimCalendar, opinion: opinions.duskOpinion) {
                let (fastName, fastHebrewName) = fastDayNames(for: yomTovIndex, isFastBegin: false)
                
                result.append(SpecialZman(
                    name: fastName,
                    hebrewName: fastHebrewName,
                    time: tzeitTime,
                    context: "Fast ends at nightfall (Tzet HaKochavim)"
                ))
            }
        }
        
        // SEFIRAT HA'OMER - show tonight's count time (at Tzet)
        let omerDay = jCal.getDayOfOmer()
        if omerDay > 0 {
            if let tzeitTime = nightfall(calendar: zmanimCalendar, opinion: opinions.duskOpinion) {
                let weekNumber = (omerDay - 1) / 7 + 1
                let dayInWeek = (omerDay - 1) % 7 + 1
                let countDisplay = omerDay <= 7 ? "Day \(omerDay)" : "Week \(weekNumber), Day \(dayInWeek)"
                
                result.append(SpecialZman(
                    labelKey: "notification_type_omer",
                    name: "Sefirat HaOmer - Count Night \(omerDay)",
                    hebrewName: "ספירת העומר - שטח \(countDisplay)",
                    time: tzeitTime,
                    context: "Count tonight: \(countDisplay) of the Omer"
                ))
            }
        }
        
        // PURIM
        if yomTovIndex == JewishCalendar.PURIM {
            // Megilla reading: evening (Tzet) and morning (after sunrise)
            if let tzeitTime = nightfall(calendar: zmanimCalendar, opinion: opinions.duskOpinion) {
                result.append(SpecialZman(
                    name: "Purim - Megilla Reading (Evening)",
                    hebrewName: "פורים - קריאת מגילה",
                    time: tzeitTime,
                    context: "Evening reading of the Megilla (Esther)"
                ))
            }
        }
        
        // EREV YOM KIPPUR - Kol Nidrei time (evening)
        if yomTovIndex == JewishCalendar.EREV_YOM_KIPPUR {
            // Get sunset or slightly before
            zmanimCalendar.setCandleLightingOffset(candleLightingOffset: opinions.shabbatCandleMinutes)
            if let candleTime = zmanimCalendar.getCandleLighting() {
                result.append(SpecialZman(
                    name: "Erev Yom Kippur - Kol Nidrei",
                    hebrewName: "ערב יום כיפור - כל נדרי",
                    time: candleTime,
                    context: "Start of Yom Kippur services (Kol Nidrei)"
                ))
            }
        }
        
        // LAG BA'OMER - bonfire time (Tzet)
        if yomTovIndex == JewishCalendar.LAG_BAOMER {
            if let tzeitTime = nightfall(calendar: zmanimCalendar, opinion: opinions.duskOpinion) {
                result.append(SpecialZman(
                    labelKey: "lag_omer_title",
                    name: "Lag Ba'Omer - Bonfire Time",
                    hebrewName: "לג בעומר - חסוני",
                    time: tzeitTime,
                    context: "Traditional bonfire lighting time (Tzet HaKochavim)"
                ))
            }
        }
        
        return result
    }

    // MARK: - Private Helpers

    /// Create a ComplexZmanimCalendar for the given date and location.
    private func makeCalendar(
        date: Date,
        location: UserLocation,
        opinions: ZmanimOpinions
    ) -> ComplexZmanimCalendar {
        let tz = TimeZone(identifier: location.timezoneId) ?? .current
        let geoLoc = KosherSwift.GeoLocation(
            locationName: location.name,
            latitude: location.latitude,
            longitude: location.longitude,
            elevation: location.elevation,
            timeZone: tz
        )
        let cal = ComplexZmanimCalendar(location: geoLoc)
        cal.workingDate = date
        cal.setUseElevation(useElevation: true)
        return cal
    }

    /// Return dawn time based on user's dawn opinion.
    private func dawnTime(calendar: ComplexZmanimCalendar, opinion: DawnOpinion) -> Date? {
        switch opinion {
        case .alot90:
            return calendar.getAlos90()
        case .alot72:
            return calendar.getAlos72()
        case .alotDegrees:
            return calendar.getAlos16Point1Degrees()
        }
    }

    /// Return sunrise based on user's sunrise opinion.
    private func sunrise(calendar: ComplexZmanimCalendar, opinion: SunriseOpinion) -> Date? {
        switch opinion {
        case .visible:
            return calendar.getSunrise()
        case .seaLevel:
            return calendar.getSeaLevelSunrise()
        }
    }

    /// Return Sof Zman Shma based on zman opinion.
    private func sofZmanShma(calendar: ComplexZmanimCalendar, opinion: ZmanOpinion) -> Date? {
        switch opinion {
        case .mga:
            return calendar.getSofZmanShmaMGA()
        case .gra:
            return calendar.getSofZmanShmaGRA()
        }
    }

    /// Return Sof Zman Tfila based on zman opinion.
    private func sofZmanTfila(calendar: ComplexZmanimCalendar, opinion: ZmanOpinion) -> Date? {
        switch opinion {
        case .mga:
            return calendar.getSofZmanTfilaMGA()
        case .gra:
            return calendar.getSofZmanTfilaGRA()
        }
    }

    /// Return nightfall based on user's dusk opinion.
    private func nightfall(calendar: ComplexZmanimCalendar, opinion: DuskOpinion) -> Date? {
        switch opinion {
        case .haravOvadia:
            return calendar.getTzaisGeonim3Point7Degrees()
        case .gra:
            return calendar.getTzais72()
        case .baalHatania:
            return calendar.getTzaisBaalHatanya()
        case .chazonIsh:
            return calendar.getTzais60()
        case .rabenuTam:
            return calendar.getTzais72()
        }
    }

    /// Calculate solar midnight: chatzot + 12 hours.
    private func solarMidnight(calendar: ComplexZmanimCalendar) -> Date? {
        guard let chatzot = calendar.getChatzos() else { return nil }
        return Calendar.current.date(byAdding: .hour, value: 12, to: chatzot)
    }

    /// Helper to get fast day names based on yomTovIndex.
    private func fastDayNames(for yomTovIndex: Int, isFastBegin: Bool) -> (String, String) {
        let begin = isFastBegin ? "Fast Begins" : "Fast Ends"
        let beginHeb = isFastBegin ? "תחילת הצום" : "סיום הצום"
        
        // Tisha B'Av is yomTovIndex = 19 in KosherSwift
        if yomTovIndex == 19 {
            return ("Tisha B'Av - \(begin)", "תשעה באב - \(beginHeb)")
        }
        return ("Fast Day - \(begin)", "צום - \(beginHeb)")
    }
}

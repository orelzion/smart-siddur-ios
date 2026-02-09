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
            name: "Dawn",
            hebrewName: "\u{05E2}\u{05DC}\u{05D5}\u{05EA} \u{05D4}\u{05E9}\u{05D7}\u{05E8}",
            time: alotTime,
            category: .dawn,
            isEssential: true
        ))

        // 2. Sunrise (Netz HaChama)
        let sunriseTime = sunrise(calendar: calendar, opinion: opinions.sunriseOpinion)
        zmanim.append(ZmanTime(
            id: "netz",
            name: "Sunrise",
            hebrewName: "\u{05E0}\u{05E5} \u{05D4}\u{05D7}\u{05DE}\u{05D4}",
            time: sunriseTime,
            category: .morning,
            isEssential: true
        ))

        // 3. Sof Zman Shma (default opinion)
        let sofShmaTime = sofZmanShma(calendar: calendar, opinion: opinions.zmanOpinion)
        let shmaLabel = opinions.zmanOpinion == .gra ? "GR\"A" : "MGA"
        zmanim.append(ZmanTime(
            id: "sofZmanShma",
            name: "Sof Zman Shma (\(shmaLabel))",
            hebrewName: "\u{05E1}\u{05D5}\u{05E3} \u{05D6}\u{05DE}\u{05DF} \u{05E9}\u{05DE}\u{05E2}",
            time: sofShmaTime,
            category: .morning,
            isEssential: true
        ))

        // 4. Sof Zman Tfila (default opinion)
        let sofTfilaTime = sofZmanTfila(calendar: calendar, opinion: opinions.zmanOpinion)
        let tfilaLabel = opinions.zmanOpinion == .gra ? "GR\"A" : "MGA"
        zmanim.append(ZmanTime(
            id: "sofZmanTfila",
            name: "Sof Zman Tfila (\(tfilaLabel))",
            hebrewName: "\u{05E1}\u{05D5}\u{05E3} \u{05D6}\u{05DE}\u{05DF} \u{05EA}\u{05E4}\u{05D9}\u{05DC}\u{05D4}",
            time: sofTfilaTime,
            category: .morning,
            isEssential: true
        ))

        // 5. Midday (Chatzot)
        zmanim.append(ZmanTime(
            id: "chatzot",
            name: "Midday",
            hebrewName: "\u{05D7}\u{05E6}\u{05D5}\u{05EA}",
            time: calendar.getChatzos(),
            category: .midday,
            isEssential: true
        ))

        // 6. Mincha Gedola
        zmanim.append(ZmanTime(
            id: "minchaGedola",
            name: "Mincha Gedola",
            hebrewName: "\u{05DE}\u{05E0}\u{05D7}\u{05D4} \u{05D2}\u{05D3}\u{05D5}\u{05DC}\u{05D4}",
            time: calendar.getMinchaGedola(),
            category: .afternoon,
            isEssential: true
        ))

        // 7. Sunset (Shkia)
        zmanim.append(ZmanTime(
            id: "shkia",
            name: "Sunset",
            hebrewName: "\u{05E9}\u{05E7}\u{05D9}\u{05E2}\u{05D4}",
            time: calendar.getElevationAdjustedSunset(),
            category: .evening,
            isEssential: true
        ))

        // 8. Nightfall (Tzeit HaKochavim)
        let tzeitTime = nightfall(calendar: calendar, opinion: opinions.duskOpinion)
        zmanim.append(ZmanTime(
            id: "tzeit",
            name: "Nightfall",
            hebrewName: "\u{05E6}\u{05D0}\u{05EA} \u{05D4}\u{05DB}\u{05D5}\u{05DB}\u{05D1}\u{05D9}\u{05DD}",
            time: tzeitTime,
            category: .night,
            isEssential: true
        ))

        // -- Comprehensive additions (isEssential = false) --

        // 9. Tallit & Tefillin (Misheyakir - earliest time)
        zmanim.append(ZmanTime(
            id: "misheyakir",
            name: "Tallit & Tefillin",
            hebrewName: "\u{05D6}\u{05DE}\u{05DF} \u{05E6}\u{05D9}\u{05E6}\u{05D9}\u{05EA} \u{05D5}\u{05EA}\u{05E4}\u{05D9}\u{05DC}\u{05D9}\u{05DF}",
            time: calendar.getMisheyakir11Point5Degrees(),
            category: .dawn,
            isEssential: false
        ))

        // 10. Sof Zman Shma (other opinion)
        let otherZmanOpinion: ZmanOpinion = opinions.zmanOpinion == .gra ? .mga : .gra
        let otherShmaLabel = otherZmanOpinion == .gra ? "GR\"A" : "MGA"
        zmanim.append(ZmanTime(
            id: "sofZmanShmaAlt",
            name: "Sof Zman Shma (\(otherShmaLabel))",
            hebrewName: "\u{05E1}\u{05D5}\u{05E3} \u{05D6}\u{05DE}\u{05DF} \u{05E9}\u{05DE}\u{05E2} (\(otherShmaLabel))",
            time: sofZmanShma(calendar: calendar, opinion: otherZmanOpinion),
            category: .morning,
            isEssential: false
        ))

        // 11. Sof Zman Tfila (other opinion)
        let otherTfilaLabel = otherZmanOpinion == .gra ? "GR\"A" : "MGA"
        zmanim.append(ZmanTime(
            id: "sofZmanTfilaAlt",
            name: "Sof Zman Tfila (\(otherTfilaLabel))",
            hebrewName: "\u{05E1}\u{05D5}\u{05E3} \u{05D6}\u{05DE}\u{05DF} \u{05EA}\u{05E4}\u{05D9}\u{05DC}\u{05D4} (\(otherTfilaLabel))",
            time: sofZmanTfila(calendar: calendar, opinion: otherZmanOpinion),
            category: .morning,
            isEssential: false
        ))

        // 12. Mincha Ketana
        zmanim.append(ZmanTime(
            id: "minchaKetana",
            name: "Mincha Ketana",
            hebrewName: "\u{05DE}\u{05E0}\u{05D7}\u{05D4} \u{05E7}\u{05D8}\u{05E0}\u{05D4}",
            time: calendar.getMinchaKetana(),
            category: .afternoon,
            isEssential: false
        ))

        // 13. Plag HaMincha
        zmanim.append(ZmanTime(
            id: "plagHamincha",
            name: "Plag HaMincha",
            hebrewName: "\u{05E4}\u{05DC}\u{05D2} \u{05D4}\u{05DE}\u{05E0}\u{05D7}\u{05D4}",
            time: calendar.getPlagHamincha(),
            category: .afternoon,
            isEssential: false
        ))

        // 14. Nightfall 72 min
        zmanim.append(ZmanTime(
            id: "tzeit72",
            name: "Nightfall 72 min",
            hebrewName: "\u{05E6}\u{05D0}\u{05EA} 72 \u{05D3}\u{05E7}\u{05D5}\u{05EA}",
            time: calendar.getTzais72(),
            category: .night,
            isEssential: false
        ))

        // 15. Nightfall Rabenu Tam
        zmanim.append(ZmanTime(
            id: "tzeitRabenuTam",
            name: "Nightfall Rabenu Tam",
            hebrewName: "\u{05E6}\u{05D0}\u{05EA} \u{05E8}\u{05D1}\u{05E0}\u{05D5} \u{05EA}\u{05DD}",
            time: calendar.getTzais72(),
            category: .night,
            isEssential: false
        ))

        // 16. Midnight (Chatzot HaLaila)
        let midnightTime = solarMidnight(calendar: calendar)
        zmanim.append(ZmanTime(
            id: "chatzotHalaila",
            name: "Midnight",
            hebrewName: "\u{05D7}\u{05E6}\u{05D5}\u{05EA} \u{05D4}\u{05DC}\u{05D9}\u{05DC}\u{05D4}",
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
                name: "Candle Lighting",
                hebrewName: "\u{05D4}\u{05D3}\u{05DC}\u{05E7}\u{05EA} \u{05E0}\u{05E8}\u{05D5}\u{05EA}",
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
                name: "Havdalah",
                hebrewName: "\u{05D4}\u{05D1}\u{05D3}\u{05DC}\u{05D4}",
                time: havdalahTime,
                category: .shabbat,
                isEssential: true
            ))
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
}

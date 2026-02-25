import Foundation

private func localizedSettingValue(_ key: String, fallback: String) -> String {
    let value = NSLocalizedString(key, comment: "")
    return value == key ? fallback : value
}

// MARK: - Synced Setting Enums

enum Nusach: String, CaseIterable, Codable, Sendable {
    case edot
    case sfarad
    case ashkenaz
    case chabad

    var displayName: String {
        switch self {
        case .edot: localizedSettingValue("nusach__0", fallback: "Edot HaMizrach")
        case .sfarad: localizedSettingValue("nusach__1", fallback: "Sfarad")
        case .ashkenaz: localizedSettingValue("nusach__2", fallback: "Ashkenaz")
        case .chabad: localizedSettingValue("nusach__3", fallback: "Chabad")
        }
    }

    var hebrewName: String {
        switch self {
        case .edot: "\u{05E2}\u{05D3}\u{05D5}\u{05EA} \u{05D4}\u{05DE}\u{05D6}\u{05E8}\u{05D7}"
        case .sfarad: "\u{05E1}\u{05E4}\u{05E8}\u{05D3}"
        case .ashkenaz: "\u{05D0}\u{05E9}\u{05DB}\u{05E0}\u{05D6}"
        case .chabad: "\u{05D7}\u{05D1}\"\u{05D3}"
        }
    }
}

enum AppLanguage: String, CaseIterable, Codable, Sendable {
    case en
    case he
    case fr
    case system
    case es
    case de

    var displayName: String {
        switch self {
        case .en: localizedSettingValue("Language__0", fallback: "English")
        case .he: localizedSettingValue("Language__1", fallback: "Hebrew")
        case .fr: localizedSettingValue("Language__2", fallback: "French")
        case .system: localizedSettingValue("Language__5", fallback: "System")
        case .es: localizedSettingValue("Language__3", fallback: "Spanish")
        case .de: localizedSettingValue("Language__4", fallback: "German")
        }
    }
}

enum MukafMode: String, CaseIterable, Codable, Sendable {
    case purim
    case shushan
    case both

    var displayName: String {
        switch self {
        case .purim: localizedSettingValue("mukaf_entries__0", fallback: "Purim (14 Adar)")
        case .shushan: localizedSettingValue("mukaf_entries__1", fallback: "Shushan Purim (15 Adar)")
        case .both: localizedSettingValue("mukaf_entries__2", fallback: "Both")
        }
    }
}

enum DateChangeRule: String, CaseIterable, Codable, Sendable {
    case sunset
    case afterSunset = "after_sunset"
    case dusk

    var displayName: String {
        switch self {
        case .sunset: localizedSettingValue("change__0", fallback: "At Sunset")
        case .afterSunset: localizedSettingValue("change__1", fallback: "After Sunset")
        case .dusk: localizedSettingValue("change__2", fallback: "At Dusk")
        }
    }
}

enum DawnOpinion: String, CaseIterable, Codable, Sendable {
    case alot90 = "alot_90"
    case alot72 = "alot_72"
    case alotDegrees = "alot_degrees"

    var displayName: String {
        switch self {
        case .alot90: localizedSettingValue("alot__0", fallback: "Alot HaShachar (90 min)")
        case .alot72: localizedSettingValue("alot__1", fallback: "Alot HaShachar (72 min)")
        case .alotDegrees: localizedSettingValue("alot__2", fallback: "Alot HaShachar (degrees)")
        }
    }
}

enum SunriseOpinion: String, CaseIterable, Codable, Sendable {
    case visible
    case seaLevel = "sea_level"

    var displayName: String {
        switch self {
        case .visible: localizedSettingValue("sunrise__0", fallback: "Visible Sunrise")
        case .seaLevel: localizedSettingValue("sunrise__1", fallback: "Sea Level Sunrise")
        }
    }
}

enum ZmanOpinion: String, CaseIterable, Codable, Sendable {
    case mga
    case gra

    var displayName: String {
        switch self {
        case .mga: localizedSettingValue("graOrMagen__0", fallback: "Magen Avraham")
        case .gra: localizedSettingValue("graOrMagen__1", fallback: "GR\"A (Vilna Gaon)")
        }
    }
}

enum DuskOpinion: String, CaseIterable, Codable, Sendable {
    case haravOvadia = "harav_ovadia"
    case gra
    case baalHatania = "baal_hatania"
    case chazonIsh = "chazon_ish"
    case rabenuTam = "rabenu_tam"

    var displayName: String {
        switch self {
        case .haravOvadia: localizedSettingValue("tzetKochav__0", fallback: "HaRav Ovadia Yosef")
        case .gra: localizedSettingValue("tzetKochav__1", fallback: "GR\"A (Vilna Gaon)")
        case .baalHatania: localizedSettingValue("tzetKochav__2", fallback: "Baal HaTania")
        case .chazonIsh: localizedSettingValue("tzetKochav__3", fallback: "Chazon Ish")
        case .rabenuTam: localizedSettingValue("tzetKochav__4", fallback: "Rabenu Tam")
        }
    }
}

// MARK: - SyncedUserSettings

/// Codable struct matching the Supabase `user_settings` table schema exactly.
/// Per MIGRATION_SPEC Section 1.3 and 6.2.
struct SyncedUserSettings: Codable, Sendable, Equatable {
    // Core identity
    var nusach: Nusach
    var isWoman: Bool
    var language: AppLanguage

    // Location/Calendar identity
    var isInIsrael: Bool
    var isMizrochnik: Bool
    var mukafMode: MukafMode
    var dateChangeRule: DateChangeRule

    // Personal prayer insertions
    var pasuk: String
    var sickName: String
    var talPreference: Bool

    // Zmanim halachic opinions
    var shabbatCandleMinutes: Int
    var shabbatEndMinutes: Int
    var dawnOpinion: DawnOpinion
    var sunriseOpinion: SunriseOpinion
    var zmanOpinion: ZmanOpinion
    var duskOpinion: DuskOpinion

    // Sync metadata
    var settingsVersion: Int

    enum CodingKeys: String, CodingKey {
        case nusach
        case isWoman = "is_woman"
        case language
        case isInIsrael = "is_in_israel"
        case isMizrochnik = "is_mizrochnik"
        case mukafMode = "mukaf_mode"
        case dateChangeRule = "date_change_rule"
        case pasuk
        case sickName = "sick_name"
        case talPreference = "tal_preference"
        case shabbatCandleMinutes = "shabbat_candle_minutes"
        case shabbatEndMinutes = "shabbat_end_minutes"
        case dawnOpinion = "dawn_opinion"
        case sunriseOpinion = "sunrise_opinion"
        case zmanOpinion = "zman_opinion"
        case duskOpinion = "dusk_opinion"
        case settingsVersion = "settings_version"
    }

    /// Default settings matching the Supabase table defaults.
    static let defaults = SyncedUserSettings(
        nusach: .edot,
        isWoman: false,
        language: .system,
        isInIsrael: false,
        isMizrochnik: false,
        mukafMode: .purim,
        dateChangeRule: .afterSunset,
        pasuk: "",
        sickName: "",
        talPreference: true,
        shabbatCandleMinutes: 20,
        shabbatEndMinutes: 1,
        dawnOpinion: .alot72,
        sunriseOpinion: .seaLevel,
        zmanOpinion: .gra,
        duskOpinion: .baalHatania,
        settingsVersion: 1
    )
}

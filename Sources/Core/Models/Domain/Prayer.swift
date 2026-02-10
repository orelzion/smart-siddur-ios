import Foundation

// MARK: - Prayer Types
/// Maps to backend PrayerType — only includes types the edge function supports
enum PrayerType: String, CaseIterable, Identifiable, Codable {
    case shacharit = "shacharit"
    case mincha = "mincha"
    case arvit = "arvit"
    case mazon = "mazon"
    case omer = "omer"
    case alMita = "al_mita"
    case chatzot = "chatzot"
    case havdala = "havdala"
    case hanuka = "hanuka"
    case levana = "levana"
    case haderech = "haderech"
    case blessings = "blessings"
    case threefold = "threefold"
    case mila = "mila"
    case shevaBrachot = "sheva_brachot"
    case maaser = "maaser"
    case hala = "hala"
    case lagBaomer = "lag_baomer"
    case ilanot = "ilanot"
    case kinot = "kinot"
    case slihot = "slihot"
    case nedarim = "nedarim"
    case asherYatzar = "asher_yatzar"
    case ushpizin = "ushpizin"
    case torahReading = "torah_reading"
    case musaf = "musaf"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .shacharit: return "Shacharit"
        case .mincha: return "Mincha"
        case .arvit: return "Arvit"
        case .mazon: return "Birkat HaMazon"
        case .omer: return "Sefirat HaOmer"
        case .alMita: return "Kriat Shema Al HaMitah"
        case .chatzot: return "Tikkun Chatzot"
        case .havdala: return "Havdala"
        case .hanuka: return "Chanukah"
        case .levana: return "Birkat HaLevana"
        case .haderech: return "Tefilat HaDerech"
        case .blessings: return "Brachot"
        case .threefold: return "Bracha Achrona"
        case .mila: return "Brit Milah"
        case .shevaBrachot: return "Sheva Brachot"
        case .maaser: return "Maaser"
        case .hala: return "Hafrashat Challah"
        case .lagBaomer: return "Lag BaOmer"
        case .ilanot: return "Birkat HaIlanot"
        case .kinot: return "Kinot"
        case .slihot: return "Selichot"
        case .nedarim: return "Hatarat Nedarim"
        case .asherYatzar: return "Asher Yatzar"
        case .ushpizin: return "Ushpizin"
        case .torahReading: return "Torah Reading"
        case .musaf: return "Musaf"
        }
    }
    
    var hebrewName: String {
        switch self {
        case .shacharit: return "שחרית"
        case .mincha: return "מנחה"
        case .arvit: return "ערבית"
        case .mazon: return "ברכת המזון"
        case .omer: return "ספירת העומר"
        case .alMita: return "קריאת שמע על המיטה"
        case .chatzot: return "תיקון חצות"
        case .havdala: return "הבדלה"
        case .hanuka: return "חנוכה"
        case .levana: return "ברכת הלבנה"
        case .haderech: return "תפילת הדרך"
        case .blessings: return "ברכות"
        case .threefold: return "ברכה אחרונה"
        case .mila: return "ברית מילה"
        case .shevaBrachot: return "שבע ברכות"
        case .maaser: return "מעשר"
        case .hala: return "הפרשת חלה"
        case .lagBaomer: return "ל\"ג בעומר"
        case .ilanot: return "ברכת האילנות"
        case .kinot: return "קינות"
        case .slihot: return "סליחות"
        case .nedarim: return "התרת נדרים"
        case .asherYatzar: return "אשר יצר"
        case .ushpizin: return "אושפיזין"
        case .torahReading: return "קריאת התורה"
        case .musaf: return "מוסף"
        }
    }
    
    var description: String {
        switch self {
        case .shacharit: return "The daily morning prayer service"
        case .mincha: return "The daily afternoon prayer service"
        case .arvit: return "The daily evening prayer service"
        case .mazon: return "Grace after meals"
        case .omer: return "Counting of the Omer between Pesach and Shavuot"
        case .alMita: return "Shema recited before sleep"
        case .chatzot: return "Midnight prayer service"
        case .havdala: return "Ceremony marking the end of Shabbat"
        case .hanuka: return "Chanukah prayers and blessings"
        case .levana: return "Blessing of the new moon"
        case .haderech: return "Traveler's prayer"
        case .blessings: return "Various blessings"
        case .threefold: return "Concluding blessing after food"
        case .mila: return "Circumcision ceremony prayers"
        case .shevaBrachot: return "Seven blessings recited at a wedding"
        case .maaser: return "Tithing prayers"
        case .hala: return "Separating challah prayers"
        case .lagBaomer: return "Lag BaOmer prayers"
        case .ilanot: return "Blessing on blossoming trees in Nisan"
        case .kinot: return "Lamentations for Tisha B'Av"
        case .slihot: return "Penitential prayers"
        case .nedarim: return "Annulment of vows"
        case .asherYatzar: return "Blessing after using the restroom"
        case .ushpizin: return "Sukkot prayers welcoming spiritual guests"
        case .torahReading: return "Torah reading service"
        case .musaf: return "Additional prayer on Shabbat and festivals"
        }
    }
}

// MARK: - Prayer Categories
enum PrayerCategory: String, CaseIterable, Codable {
    case morning = "morning"
    case afternoon = "afternoon"
    case evening = "evening"
    case special = "special"
    
    var displayName: String {
        switch self {
        case .morning: return "Morning"
        case .afternoon: return "Afternoon"
        case .evening: return "Evening"
        case .special: return "Special Occasions"
        }
    }
    
    var hebrewName: String {
        switch self {
        case .morning: return "בוקר"
        case .afternoon: return "צהריים"
        case .evening: return "ערב"
        case .special: return "מאורעות מיוחדים"
        }
    }
}

// MARK: - Prayer Data Structures
struct Prayer: Identifiable, Codable {
    let id: String
    let type: PrayerType
    let category: PrayerCategory
    let displayName: String
    let hebrewName: String
    let description: String
    
    init(type: PrayerType) {
        self.id = type.rawValue
        self.type = type
        self.category = Self.category(for: type)
        self.displayName = type.displayName
        self.hebrewName = type.hebrewName
        self.description = type.description
    }
    
    private static func category(for type: PrayerType) -> PrayerCategory {
        switch type {
        case .shacharit:
            return .morning
        case .mincha:
            return .afternoon
        case .arvit, .alMita, .chatzot:
            return .evening
        case .mazon, .omer, .havdala, .hanuka, .levana, .haderech, .blessings,
             .threefold, .mila, .shevaBrachot, .maaser, .hala, .lagBaomer,
             .ilanot, .kinot, .slihot, .nedarim, .asherYatzar, .ushpizin,
             .torahReading, .musaf:
            return .special
        }
    }
}

// MARK: - Prayer Request/Response (matches backend GeneratePrayerRequest)

/// Location info required by the edge function
struct PrayerLocationInfo: Codable {
    let latitude: Double
    let longitude: Double
    let elevation: Double
    let timezoneId: String
    let countryCode: String
    let isInIsrael: Bool
    
    enum CodingKeys: String, CodingKey {
        case latitude, longitude, elevation
        case timezoneId = "timezone_id"
        case countryCode = "country_code"
        case isInIsrael = "is_in_israel"
    }
    
    /// Create from a UserLocation
    init(from location: UserLocation) {
        self.latitude = location.latitude
        self.longitude = location.longitude
        self.elevation = location.elevation
        self.timezoneId = location.timezoneId
        self.countryCode = location.countryCode
        self.isInIsrael = location.countryCode == "IL"
    }
    
    /// Default location (Jerusalem)
    static let defaultLocation = PrayerLocationInfo(
        latitude: 31.7683,
        longitude: 35.2137,
        elevation: 754,
        timezoneId: "Asia/Jerusalem",
        countryCode: "IL",
        isInIsrael: true
    )
    
    init(latitude: Double, longitude: Double, elevation: Double, timezoneId: String, countryCode: String, isInIsrael: Bool) {
        self.latitude = latitude
        self.longitude = longitude
        self.elevation = elevation
        self.timezoneId = timezoneId
        self.countryCode = countryCode
        self.isInIsrael = isInIsrael
    }
}

/// Settings required by the edge function
struct PrayerSettings: Codable {
    let isWoman: Bool
    let isAvel: Bool
    let noTahanun: Bool
    let isVanenu: Bool
    let nachemAlways: Bool
    let talPreference: Bool
    let isMizrochnik: Bool
    let mukafMode: String
    let sickName: String
    let pasuk: String
    let language: String
    
    enum CodingKeys: String, CodingKey {
        case isWoman = "is_woman"
        case isAvel = "is_avel"
        case noTahanun = "no_tahanun"
        case isVanenu = "is_vanenu"
        case nachemAlways = "nachem_always"
        case talPreference = "tal_preference"
        case isMizrochnik = "is_mizrochnik"
        case mukafMode = "mukaf_mode"
        case sickName = "sick_name"
        case pasuk
        case language
    }
    
    /// Create from LocalSettings
    @MainActor
    init(from localSettings: LocalSettings) {
        self.isWoman = false // Not yet in LocalSettings
        self.isAvel = localSettings.isAvel
        self.noTahanun = localSettings.noTahanun
        self.isVanenu = localSettings.isVanenu
        self.nachemAlways = localSettings.nachemAlways
        self.talPreference = false // Not yet in LocalSettings
        self.isMizrochnik = false // Not yet in LocalSettings
        self.mukafMode = "purim" // Default
        self.sickName = "" // Not yet in LocalSettings
        self.pasuk = "" // Not yet in LocalSettings
        self.language = "hebrew"
    }
}

struct PrayerRequest: Codable {
    let prayerType: String
    let date: String // ISO 8601 YYYY-MM-DD
    let nusach: String
    let tfilaMode: String
    let location: PrayerLocationInfo
    let settings: PrayerSettings
    
    enum CodingKeys: String, CodingKey {
        case prayerType = "prayer_type"
        case date, nusach
        case tfilaMode = "tfila_mode"
        case location, settings
    }
}

/// Matches backend GeneratePrayerResponse
struct PrayerResponse: Codable {
    let prayerType: String
    let generatedForDate: String
    let items: [PrayerTextItem]
    let menu: [MenuEntry]
    let metadata: PrayerResponseMetadata
    
    enum CodingKeys: String, CodingKey {
        case prayerType = "prayer_type"
        case generatedForDate = "generated_for_date"
        case items, menu, metadata
    }
}

struct PrayerTextItem: Codable, Identifiable {
    let id: String
    let title: String?
    let text: String
    let expand: String // "expanded", "collapsed", "none"
    let showTitle: Bool
    let sortOrder: Int
    
    enum CodingKeys: String, CodingKey {
        case id, title, text, expand
        case showTitle = "show_title"
        case sortOrder = "sort_order"
    }
}

struct MenuEntry: Codable, Identifiable {
    let index: Int
    let title: String
    
    var id: Int { index }
}

struct PrayerResponseMetadata: Codable {
    let jewishDate: String
    let isShabbat: Bool
    let isYomTov: Bool
    let isCholHamoed: Bool
    let isRoshChodesh: Bool
    let isTaanis: Bool
    let yomTovName: String?
    let parsha: String?
    let omerDay: Int?
    let contentVersion: Int
    
    enum CodingKeys: String, CodingKey {
        case jewishDate = "jewish_date"
        case isShabbat = "is_shabbat"
        case isYomTov = "is_yom_tov"
        case isCholHamoed = "is_chol_hamoed"
        case isRoshChodesh = "is_rosh_chodesh"
        case isTaanis = "is_taanis"
        case yomTovName = "yom_tov_name"
        case parsha
        case omerDay = "omer_day"
        case contentVersion = "content_version"
    }
}

// MARK: - Prayer Metadata (for backward compatibility with cache)
struct PrayerMetadata: Codable {
    let generatedAt: String
    let nusach: String
    let date: String
    let location: String?
    let specialOccasion: String?
}

// MARK: - Prayer Organization
struct PrayerSection: Identifiable {
    let id = UUID()
    let category: PrayerCategory
    let prayers: [Prayer]
    
    var title: String {
        return category.displayName
    }
    
    var hebrewTitle: String {
        return category.hebrewName
    }
}

// Helper to organize prayers by category
extension Array where Element == Prayer {
    func organizedByCategory() -> [PrayerSection] {
        let grouped = Dictionary(grouping: self) { $0.category }
        
        return PrayerCategory.allCases.compactMap { category in
            guard let prayers = grouped[category], !prayers.isEmpty else { return nil }
            return PrayerSection(category: category, prayers: prayers.sorted { $0.type.displayName < $1.type.displayName })
        }
    }
}
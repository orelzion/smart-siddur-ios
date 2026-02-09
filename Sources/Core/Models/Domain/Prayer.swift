import Foundation

// MARK: - Prayer Types
enum PrayerType: String, CaseIterable, Identifiable, Codable {
    // Morning prayers
    case birchotHaShachar = "birchot_hashachar"
    case psukeiDezimra = "psukei_dezimra"
    case shacharit = "shacharit"
    case korbanot = "korbanot"
    case tachanun = "tachanun"
    
    // Afternoon prayers
    case mincha = "mincha"
    case minchaGedola = "mincha_gedola"
    case minchaKetana = "mincha_ketana"
    case neilat = "neilat"
    
    // Evening prayers
    case arvit = "arvit"
    case kriatShemaAlHaMitah = "kriat_shema_al_ha_mitah"
    case chatzot = "chatzot"
    
    // Special occasion prayers
    case hallel = "hallel"
    case musaf = "musaf"
    case selichot = "selichot"
    case vidui = "vidui"
    case alChet = "al_chet"
    case avodah = "avodah"
    case kriatHaTorah = "kriat_ha_torah"
    case aleinu = "aleinu"
    case kaddish = "kaddish"
    case barchu = "barchu"
    case kedusha = "kedusha"
    case shema = "shema"
    case amidah = "amidah"
    case ashrei = "ashrei"
    case lamnatzeach = "lamnatzeach"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .birchotHaShachar: return "Birchot HaShachar"
        case .psukeiDezimra: return "Psukei Dezimra"
        case .shacharit: return "Shacharit"
        case .korbanot: return "Korbanot"
        case .tachanun: return "Tachanun"
        case .mincha: return "Mincha"
        case .minchaGedola: return "Mincha Gedola"
        case .minchaKetana: return "Mincha Ketana"
        case .neilat: return "Neilat"
        case .arvit: return "Arvit"
        case .kriatShemaAlHaMitah: return "Kriat Shema Al HaMitah"
        case .chatzot: return "Chatzot"
        case .hallel: return "Hallel"
        case .musaf: return "Musaf"
        case .selichot: return "Selichot"
        case .vidui: return "Vidui"
        case .alChet: return "Al Chet"
        case .avodah: return "Avodah"
        case .kriatHaTorah: return "Kriat HaTorah"
        case .aleinu: return "Aleinu"
        case .kaddish: return "Kaddish"
        case .barchu: return "Barchu"
        case .kedusha: return "Kedusha"
        case .shema: return "Shema"
        case .amidah: return "Amidah"
        case .ashrei: return "Ashrei"
        case .lamnatzeach: return "Lamnatzeach"
        }
    }
    
    var hebrewName: String {
        switch self {
        case .birchotHaShachar: return "ברכות השחר"
        case .psukeiDezimra: return "פסוקי דזמרא"
        case .shacharit: return "שחרית"
        case .korbanot: return "קרבנות"
        case .tachanun: return "תחנון"
        case .mincha: return "מנחה"
        case .minchaGedola: return "מנחה גדולה"
        case .minchaKetana: return "מנחה קטנה"
        case .neilat: return "נעילה"
        case .arvit: return "ערבית"
        case .kriatShemaAlHaMitah: return "קריאת שמע על המיטה"
        case .chatzot: return "חצות"
        case .hallel: return "הלל"
        case .musaf: return "מוסף"
        case .selichot: return "סליחות"
        case .vidui: return "וידוי"
        case .alChet: return "על חטא"
        case .avodah: return "עבודה"
        case .kriatHaTorah: return "קריאת התורה"
        case .aleinu: return "עלינו לשבח"
        case .kaddish: return "קדיש"
        case .barchu: return "ברכו"
        case .kedusha: return "קדושה"
        case .shema: return "שמע"
        case .amidah: return "עמידה"
        case .ashrei: return "אשרי"
        case .lamnatzeach: return "למנצח"
        }
    }
    
    var description: String {
        switch self {
        case .birchotHaShachar: return "Morning blessings recited before Shacharit"
        case .psukeiDezimra: return "Verses of praise recited before Shacharit"
        case .shacharit: return "The daily morning prayer service"
        case .korbanot: return "Prayers related to Temple offerings"
        case .tachanun: return "Supplicatory prayer recited after Amidah"
        case .mincha: return "The daily afternoon prayer service"
        case .minchaGedola: return "The earlier time for Mincha prayer"
        case .minchaKetana: return "The later time for Mincha prayer"
        case .neilat: return "The closing prayer on Yom Kippur"
        case .arvit: return "The daily evening prayer service"
        case .kriatShemaAlHaMitah: return "Shema recited before sleep"
        case .chatzot: return "Midnight prayer service"
        case .hallel: return "Psalms of praise recited on festivals"
        case .musaf: return "Additional prayer service on Shabbat and festivals"
        case .selichot: return "Penitential prayers recited in Elul and High Holidays"
        case .vidui: return "Confession prayer recited on Yom Kippur and fast days"
        case .alChet: return "Confession of sins recited on Yom Kippur"
        case .avodah: return "Temple service description recited on Yom Kippur"
        case .kriatHaTorah: return "Torah reading service"
        case .aleinu: return "Concluding prayer of all services"
        case .kaddish: return "Sanctification prayer recited by mourners"
        case .barchu: return "Call to prayer before Shema and Amidah"
        case .kedusha: return "Sanctification recited in Amidah repetition"
        case .shema: return "Declaration of faith recited twice daily"
        case .amidah: return "The central silent prayer"
        case .ashrei: return "Psalm 145 recited in afternoon service"
        case .lamnatzeach: return "Psalm for the conductor, recited in certain contexts"
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
        case .birchotHaShachar, .psukeiDezimra, .shacharit, .korbanot, .tachanun:
            return .morning
        case .mincha, .minchaGedola, .minchaKetana, .neilat:
            return .afternoon
        case .arvit, .kriatShemaAlHaMitah, .chatzot:
            return .evening
        case .hallel, .musaf, .selichot, .vidui, .alChet, .avodah, .kriatHaTorah, .aleinu, .kaddish, .barchu, .kedusha, .shema, .amidah, .ashrei, .lamnatzeach:
            return .special
        }
    }
}

// MARK: - Prayer Request/Response
struct PrayerRequest: Codable {
    let type: PrayerType
    let date: Date
    let nusach: String
    let location: String?
    let tfilaMode: String?
    
    enum CodingKeys: String, CodingKey {
        case type, date, nusach, location, tfilaMode
    }
}

struct PrayerResponse: Codable {
    let prayer: PrayerText
    let metadata: PrayerMetadata
}

struct PrayerMetadata: Codable {
    let generatedAt: Date
    let nusach: String
    let date: Date
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
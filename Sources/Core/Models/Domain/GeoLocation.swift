import Foundation

/// Domain model matching the Supabase `geo_locations` table.
/// Per MIGRATION_SPEC Section 1.5.
struct GeoLocation: Codable, Identifiable, Sendable, Equatable {
    let geonameId: String
    let name: String
    let countryCode: String
    let countryName: String
    let elevation: String?
    let timezone: String
    let modificationDate: String?
    let latitude: Double
    let longitude: Double

    var id: String { geonameId }

    enum CodingKeys: String, CodingKey {
        case geonameId = "geoname_id"
        case name
        case countryCode = "country_code"
        case countryName = "country_name"
        case elevation
        case timezone
        case modificationDate = "modification_date"
        case latitude
        case longitude
    }

    /// Derive a flag emoji from the 2-letter country code.
    var countryFlag: String {
        let base: UInt32 = 127397
        return countryCode.uppercased().unicodeScalars.compactMap {
            UnicodeScalar(base + $0.value).map(String.init)
        }.joined()
    }

    /// Display string: "City, Country"
    var displayName: String {
        "\(name), \(countryName)"
    }
}

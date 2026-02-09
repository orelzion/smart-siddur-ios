import Foundation

/// Domain model matching the Supabase `user_locations` table.
/// Per MIGRATION_SPEC Section 1.4.
struct UserLocation: Codable, Identifiable, Sendable, Equatable {
    let id: UUID
    let userId: UUID
    var geonameId: String?
    var name: String
    var countryCode: String
    var countryName: String
    var latitude: Double
    var longitude: Double
    var elevation: Double
    var timezoneId: String
    var isSelected: Bool
    var isFromGps: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case geonameId = "geoname_id"
        case name
        case countryCode = "country_code"
        case countryName = "country_name"
        case latitude
        case longitude
        case elevation
        case timezoneId = "timezone_id"
        case isSelected = "is_selected"
        case isFromGps = "is_from_gps"
    }

    /// Display string: "City, Country"
    var displayName: String {
        "\(name), \(countryName)"
    }

    /// Derive a flag emoji from the 2-letter country code.
    var countryFlag: String {
        let base: UInt32 = 127397
        return countryCode.uppercased().unicodeScalars.compactMap {
            UnicodeScalar(base + $0.value).map(String.init)
        }.joined()
    }
}

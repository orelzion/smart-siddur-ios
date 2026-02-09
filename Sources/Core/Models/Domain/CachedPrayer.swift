import Foundation
import SwiftData
import CommonCrypto

// MARK: - Cached Prayer Model
/// SwiftData model for persistent offline storage of rendered prayer content.
/// Enables seamless offline access to prayers with intelligent cache invalidation.
@Model
final class CachedPrayer {
    // MARK: - Primary Key & Identity
    /// Unique identifier for this cached prayer entry
    var id: UUID
    
    // MARK: - Prayer Identification
    /// Type of prayer (shacharit, mincha, etc.)
    var prayerType: String
    
    /// Date this prayer is for (start of day)
    var date: Date
    
    // MARK: - Settings Context
    /// Nusach used for this prayer (ashkenaz, sefard, etc.)
    var nusach: String
    
    /// Location identifier for geo-specific prayers
    var locationId: UUID?
    
    /// Hash of settings that affect prayer content (nusach, location, tfilaMode)
    var settingsHash: String
    
    // MARK: - Content
    /// Full rendered prayer text as JSON string
    var content: String
    
    /// Backend content version for detecting updates
    var contentVersion: Int
    
    // MARK: - Cache Metadata
    /// When this prayer was cached
    var cachedAt: Date
    
    /// When this cache entry expires
    var expiresAt: Date
    
    // MARK: - Initialization
    init(
        id: UUID = UUID(),
        prayerType: String,
        date: Date,
        nusach: String,
        locationId: UUID? = nil,
        settingsHash: String,
        content: String,
        contentVersion: Int = 1,
        cachedAt: Date = Date(),
        expiresAt: Date
    ) {
        self.id = id
        self.prayerType = prayerType
        self.date = date
        self.nusach = nusach
        self.locationId = locationId
        self.settingsHash = settingsHash
        self.content = content
        self.contentVersion = contentVersion
        self.cachedAt = cachedAt
        self.expiresAt = expiresAt
    }
    
    // MARK: - Cache Key Generation
    /// Generates a unique cache key for this prayer + settings combination
    var cacheKey: String {
        "\(prayerType)_\(date.timeIntervalSince1970)_\(settingsHash)"
    }
    
    // MARK: - Expiration Check
    /// Whether this cache entry has expired
    var isExpired: Bool {
        Date() > expiresAt
    }
    
    // MARK: - Content Decoding
    /// Decodes the cached content as PrayerText
    var decodedContent: PrayerText? {
        guard let data = content.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(PrayerText.self, from: data)
    }
    
    // MARK: - Domain Conversion
    /// Converts to CachedPrayerDomain for use in app
    func toDomain() -> CachedPrayerDomain {
        CachedPrayerDomain(
            prayerType: PrayerType(rawValue: prayerType) ?? .shacharit,
            date: date,
            nusach: nusach,
            locationId: locationId,
            settingsHash: settingsHash,
            content: decodedContent,
            contentVersion: contentVersion,
            cachedAt: cachedAt,
            expiresAt: expiresAt
        )
    }
}

// MARK: - Domain Model
/// Domain model representing cached prayer data for app use
struct CachedPrayerDomain {
    let prayerType: PrayerType
    let date: Date
    let nusach: String
    let locationId: UUID?
    let settingsHash: String
    let content: PrayerText?
    let contentVersion: Int
    let cachedAt: Date
    let expiresAt: Date
    
    var isExpired: Bool {
        Date() > expiresAt
    }
}

// MARK: - Cache Configuration
/// Configuration constants for prayer cache behavior
enum CacheConfig {
    /// Default cache duration in seconds (7 days)
    static let defaultExpiration: TimeInterval = 7 * 24 * 60 * 60
    
    /// Calendar-sensitive prayer expiration (1 day)
    static let calendarSensitiveExpiration: TimeInterval = 24 * 60 * 60
    
    /// Maximum number of days to pre-fetch
    static let preFetchDays: Int = 14
    
    /// Minimum interval between cache refreshes (12 hours)
    static let minRefreshInterval: TimeInterval = 12 * 60 * 60
    
    /// Background refresh interval (24 hours)
    static let backgroundRefreshInterval: TimeInterval = 24 * 60 * 60
    
    /// Maximum cache size in bytes (50MB)
    static let maxCacheSize: Int = 50 * 1024 * 1024
    
    /// Prayer types considered calendar-sensitive (require shorter expiration)
    static let calendarSensitivePrayers: Set<PrayerType> = [
        .hallel, .musaf, .selichot
    ]
    
    /// Determines expiration duration for a prayer type
    static func expiration(for prayerType: PrayerType) -> TimeInterval {
        if calendarSensitivePrayers.contains(prayerType) {
            return calendarSensitiveExpiration
        }
        return defaultExpiration
    }
}

// MARK: - Settings Hash Generation
/// Generates settings hash for cache invalidation based on relevant settings
struct SettingsHashGenerator {
    /// Generates hash string from relevant settings
    static func hash(nusach: String, locationId: UUID?, tfilaMode: String?) -> String {
        let components = [
            nusach,
            locationId?.uuidString ?? "default",
            tfilaMode ?? "default"
        ]
        
        let joined = components.joined(separator: "|")
        let data = Data(joined.utf8)
        var hash = [UInt8](repeating: 0, count: 32)
        
        data.withUnsafeBytes { buffer in
            _ = CC_SHA256(buffer.baseAddress, CC_LONG(buffer.count), &hash)
        }
        
        return hash.map { String(format: "%02x", $0) }.joined()
    }
}

// MARK: - CommonCrypto Bridge
import CommonCrypto

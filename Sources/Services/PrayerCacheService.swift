import Foundation
import SwiftData
import Observation

// MARK: - Prayer Cache Service
/// Service for managing prayer content caching using SwiftData.
/// Provides 14-day pre-fetch, intelligent cache invalidation, and offline access.
@MainActor
final class PrayerCacheService: Observable {
    // MARK: - Dependencies
    private let modelContext: ModelContext
    private let prayerService: PrayerService
    private let localSettings: LocalSettings
    
    // MARK: - Cache State
    private var lastRefreshDate: Date?
    private var currentContentVersion: Int = 1
    
    // MARK: - Initialization
    init(modelContext: ModelContext, prayerService: PrayerService, localSettings: LocalSettings) {
        self.modelContext = modelContext
        self.prayerService = prayerService
        self.localSettings = localSettings
    }
    
    // MARK: - Public API
    
    /// Prefetches prayers for a date range using batch API
    func prefetchPrayers(from startDate: Date, to endDate: Date) async throws {
        let settingsHash = generateSettingsHash()
        let nusach = getNusach()
        
        // Get content version from backend
        currentContentVersion = try await fetchContentVersion()
        
        // Generate prayers for each day in range
        let responses = try await prayerService.generatePrayerBatch(
            from: startDate,
            to: endDate,
            nusach: nusach
        )
        
        // Cache each prayer
        for response in responses {
            let prayerType = response.metadata.specialOccasion ?? "daily"
            let date = response.metadata.date
            
            try await cachePrayer(
                type: PrayerType(rawValue: prayerType) ?? .shacharit,
                date: date,
                content: response.prayer,
                settingsHash: settingsHash
            )
        }
        
        lastRefreshDate = Date()
    }
    
    /// Gets cached prayer or fetches from network if not cached
    func getCachedPrayer(
        type: PrayerType,
        date: Date
    ) async throws -> CachedPrayerDomain? {
        let settingsHash = generateSettingsHash()
        
        // Try to find cached prayer
        if let cached = try await findCachedPrayer(
            type: type,
            date: date,
            settingsHash: settingsHash
        ) {
            // Check if expired
            if cached.isExpired {
                // Try to refresh from network
                if let fresh = try await refreshPrayer(type: type, date: date, settingsHash: settingsHash) {
                    return fresh
                }
                // Return expired cache as fallback
                return cached
            }
            return cached
        }
        
        // Not cached - fetch from network
        return try await refreshPrayer(type: type, date: date, settingsHash: settingsHash)
    }
    
    /// Invalidates all cached prayers
    func invalidateCache() async throws {
        let descriptor = FetchDescriptor<CachedPrayer>()
        let prayers = try modelContext.fetch(descriptor)
        
        for prayer in prayers {
            modelContext.delete(prayer)
        }
        
        try modelContext.save()
        lastRefreshDate = nil
    }
    
    /// Invalidates cache for specific settings
    func invalidateCache(for settingsHash: String) async throws {
        let predicate = #Predicate<CachedPrayer> { prayer in
            prayer.settingsHash == settingsHash
        }
        
        let descriptor = FetchDescriptor<CachedPrayer>(predicate: predicate)
        let prayers = try modelContext.fetch(descriptor)
        
        for prayer in prayers {
            modelContext.delete(prayer)
        }
        
        try modelContext.save()
    }
    
    /// Performs background cache refresh if needed
    func performBackgroundRefreshIfNeeded() async throws {
        guard let lastRefresh = lastRefreshDate else {
            // Never refreshed - do full pre-fetch
            try await performFullPrefetch()
            return
        }
        
        let timeSinceRefresh = Date().timeIntervalSince(lastRefresh)
        
        // Refresh if more than 12 hours old
        if timeSinceRefresh > CacheConfig.minRefreshInterval {
            try await performFullPrefetch()
        }
    }
    
    /// Gets cache statistics for debugging
    func getCacheStats() async throws -> CacheStats {
        let descriptor = FetchDescriptor<CachedPrayer>()
        let allPrayers = try modelContext.fetch(descriptor)
        
        let now = Date()
        let expired = allPrayers.filter { $0.expiresAt < now }.count
        let valid = allPrayers.count - expired
        
        return CacheStats(
            totalEntries: allPrayers.count,
            validEntries: valid,
            expiredEntries: expired,
            lastRefresh: lastRefreshDate
        )
    }
    
    // MARK: - Private Methods
    
    private func performFullPrefetch() async throws {
        let today = Calendar.current.startOfDay(for: Date())
        let endDate = Calendar.current.date(byAdding: .day, value: CacheConfig.preFetchDays, to: today)!
        
        try await prefetchPrayers(from: today, to: endDate)
    }
    
    private func generateSettingsHash() -> String {
        SettingsHashGenerator.hash(
            nusach: getNusach(),
            locationId: localSettings.selectedLocationId,
            tfilaMode: localSettings.tfilaMode?.rawValue
        )
    }
    
    private func getNusach() -> String {
        // Get nusach from settings - placeholder until LocalSettings is updated
        return "ashkenaz"
    }
    
    private func findCachedPrayer(
        type: PrayerType,
        date: Date,
        settingsHash: String
    ) async throws -> CachedPrayerDomain? {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = #Predicate<CachedPrayer> { prayer in
            prayer.prayerType == type.rawValue &&
            prayer.date >= startOfDay &&
            prayer.date < endOfDay &&
            prayer.settingsHash == settingsHash
        }
        
        let descriptor = FetchDescriptor<CachedPrayer>(predicate: predicate)
        let prayers = try modelContext.fetch(descriptor)
        
        // Return first matching prayer (should be unique)
        return prayers.first?.toDomain()
    }
    
    private func cachePrayer(
        type: PrayerType,
        date: Date,
        content: PrayerText,
        settingsHash: String
    ) async throws {
        // Delete existing cache entry for this prayer
        if let existing = try await findCachedPrayer(type: type, date: date, settingsHash: settingsHash) {
            let descriptor = FetchDescriptor<CachedPrayer>(
                predicate: #Predicate { $0.id == existing.id }
            )
            let prayers = try modelContext.fetch(descriptor)
            for prayer in prayers {
                modelContext.delete(prayer)
            }
        }
        
        // Encode content to JSON string
        let encoder = JSONEncoder()
        let contentData = try encoder.encode(content)
        guard let contentString = String(data: contentData, encoding: .utf8) else {
            throw CacheError.encodingFailed
        }
        
        // Create new cache entry
        let cachedPrayer = CachedPrayer(
            prayerType: type.rawValue,
            date: Calendar.current.startOfDay(for: date),
            nusach: getNusach(),
            locationId: localSettings.selectedLocationId,
            settingsHash: settingsHash,
            content: contentString,
            contentVersion: currentContentVersion,
            cachedAt: Date(),
            expiresAt: Date().addingTimeInterval(CacheConfig.expiration(for: type))
        )
        
        modelContext.insert(cachedPrayer)
        try modelContext.save()
    }
    
    private func refreshPrayer(
        type: PrayerType,
        date: Date,
        settingsHash: String
    ) async throws -> CachedPrayerDomain? {
        do {
            let response = try await prayerService.generatePrayer(
                type: type,
                date: date,
                nusach: getNusach(),
                location: nil, // TODO: Get location from settings
                tfilaMode: localSettings.tfilaMode?.rawValue
            )
            
            try await cachePrayer(
                type: type,
                date: date,
                content: response.prayer,
                settingsHash: settingsHash
            )
            
            return try await findCachedPrayer(type: type, date: date, settingsHash: settingsHash)
        } catch {
            // Network failed - return nil
            return nil
        }
    }
    
    private func fetchContentVersion() async throws -> Int {
        // TODO: Implement content version checking from backend
        return 1
    }
}

// MARK: - Cache Errors
enum CacheError: LocalizedError {
    case encodingFailed
    case decodingFailed
    case notFound
    case saveFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .encodingFailed:
            return "Failed to encode prayer content for caching"
        case .decodingFailed:
            return "Failed to decode cached prayer content"
        case .notFound:
            return "Cached prayer not found"
        case .saveFailed(let reason):
            return "Failed to save cache: \(reason)"
        }
    }
}

// MARK: - Cache Statistics
struct CacheStats {
    let totalEntries: Int
    let validEntries: Int
    let expiredEntries: Int
    let lastRefresh: Date?
    
    var utilizationPercentage: Double {
        guard totalEntries > 0 else { return 0 }
        return Double(validEntries) / Double(totalEntries) * 100
    }
}

// MARK: - LocalSettings Extension
/// Extension to add cache-related properties to LocalSettings
extension LocalSettings {
    /// Selected location ID for geo-specific prayers
    var selectedLocationId: UUID? {
        get { nil } // TODO: Implement
        set { }     // TODO: Implement
    }
    
    /// Current nusach setting
    var nusach: Nusach {
        get { .ashkenaz } // TODO: Implement actual property
        set { }          // TODO: Implement
    }
    
    /// Current tfila mode setting
    var tfilaMode: TfilaMode? {
        get { nil } // TODO: Implement
        set { }     // TODO: Implement
    }
}

// MARK: - Placeholder Enums
/// Placeholder enum for Nusach - should be replaced with actual implementation
enum Nusach: String, Codable {
    case ashkenaz = "ashkenaz"
    case sefard = "sefard"
    case edot = "edot"
}

/// Placeholder enum for TfilaMode - should be replaced with actual implementation  
enum TfilaMode: String, Codable {
    case standard = "standard"
    case arizal = "arizal"
}

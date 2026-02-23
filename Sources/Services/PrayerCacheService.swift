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
    private let locationRepository: LocationRepositoryProtocol
    private let getSyncedSettings: () async -> SyncedUserSettings
    
    // MARK: - Cache State
    private var lastRefreshDate: Date?
    private var currentContentVersion: Int = 1
    
    // MARK: - Initialization
    init(modelContext: ModelContext, prayerService: PrayerService, localSettings: LocalSettings, locationRepository: LocationRepositoryProtocol, getSyncedSettings: @escaping () async -> SyncedUserSettings = { SyncedUserSettings.defaults }) {
        self.modelContext = modelContext
        self.prayerService = prayerService
        self.localSettings = localSettings
        self.locationRepository = locationRepository
        self.getSyncedSettings = getSyncedSettings
    }
    
    // MARK: - Public API
    
    /// Prefetches prayers for a date range using batch API
    func prefetchPrayers(from startDate: Date, to endDate: Date) async throws {
        let location = await getLocationInfo()

        // Get synced settings (with fallback to defaults)
        let syncedSettings = await getSyncedSettings()
        let settings = PrayerSettings(from: localSettings, syncedSettings: syncedSettings)
        let nusach = syncedSettings.nusach.rawValue
        let tfilaModeString = localSettings.tfilaMode.rawValue

        // Generate settings hash with synced nusach
        let settingsHash = SettingsHashGenerator.hash(
            nusach: nusach,
            locationId: localSettings.locationName,
            tfilaMode: tfilaModeString
        )

        // Get content version from backend
        currentContentVersion = try await fetchContentVersion()
        
        // Calculate number of days
        let calendar = Calendar.current
        let days = max(1, calendar.dateComponents([.day], from: startDate, to: endDate).day ?? 1)
        
        // Main daily prayers to pre-fetch
        let prayerTypes: [PrayerType] = [.shacharit, .mincha, .arvit]
        
        // Generate prayers using batch API
        let batchResponse = try await prayerService.generatePrayerBatch(
            prayerTypes: prayerTypes,
            startDate: startDate,
            days: days,
            nusach: nusach,
            location: location,
            tfilaMode: tfilaModeString,
            settings: settings
        )
        
        // Cache each prayer from batch response
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.timeZone = .current
        
        for entry in batchResponse.prayers {
            let entryDate = dateFormatter.date(from: entry.date) ?? startDate
            try await cachePrayer(
                type: PrayerType(rawValue: entry.prayerType) ?? .shacharit,
                date: entryDate,
                content: entry.items,
                settingsHash: settingsHash,
                nusach: nusach
            )
        }
        
        lastRefreshDate = Date()
    }
    
    /// Gets cached prayer or fetches from network if not cached
    func getCachedPrayer(
        type: PrayerType,
        date: Date
    ) async throws -> CachedPrayerDomain? {
        let settingsHash = await generateSettingsHash()

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
    
    /// Saves a prayer to cache after network fetch
    /// Called by PrayerTextViewModel after successful network response
    func savePrayer(
        type: PrayerType,
        date: Date,
        content: [PrayerTextItem],
        settingsHash: String? = nil
    ) async throws {
        let hash: String
        if let settingsHash = settingsHash {
            hash = settingsHash
        } else {
            hash = await generateSettingsHash()
        }
        try await cachePrayer(type: type, date: date, content: content, settingsHash: hash)
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
    
    /// Performs a full 14-day pre-fetch of all prayers
    private func performFullPrefetch() async throws {
        let today = Calendar.current.startOfDay(for: Date())
        let endDate = Calendar.current.date(byAdding: .day, value: CacheConfig.preFetchDays, to: today)!
        
        try await prefetchPrayers(from: today, to: endDate)
    }
    
    /// Gets the current content version from backend
    private func fetchContentVersion() async throws -> Int {
        // TODO: Implement backend content version check
        // For now, return cached version or default
        return currentContentVersion
    }
    
    /// Checks if backend content has been updated
    func checkForContentUpdates() async throws -> Bool {
        let newVersion = try await fetchContentVersion()
        guard newVersion != currentContentVersion else {
            return false
        }
        
        // Content has been updated - invalidate cache
        try await invalidateCache()
        currentContentVersion = newVersion
        return true
    }
    
    /// Gets cache statistics for debugging/monitoring
    func getCacheStatistics() async throws -> CacheStatistics {
        let descriptor = FetchDescriptor<CachedPrayer>()
        let allPrayers = try modelContext.fetch(descriptor)
        
        let now = Date()
        let expired = allPrayers.filter { $0.expiresAt < now }.count
        let valid = allPrayers.count - expired
        let totalSize = allPrayers.reduce(0) { sum, prayer in
            sum + prayer.content.count
        }
        
        return CacheStatistics(
            totalEntries: allPrayers.count,
            validEntries: valid,
            expiredEntries: expired,
            totalSizeBytes: totalSize,
            lastRefreshDate: lastRefreshDate
        )
    }
    
    // MARK: - Private Methods
    
    private func generateSettingsHash() async -> String {
        let syncedSettings = await getSyncedSettings()
        let nusach = syncedSettings.nusach.rawValue
        return SettingsHashGenerator.hash(
            nusach: nusach,
            locationId: localSettings.locationName,
            tfilaMode: localSettings.tfilaMode.rawValue
        )
    }
    
    /// Gets PrayerLocationInfo from the selected location, or default
    private func getLocationInfo() async -> PrayerLocationInfo {
        if let selectedLoc = try? await locationRepository.getSelectedLocation() {
            return PrayerLocationInfo(from: selectedLoc)
        }
        return .defaultLocation
    }
    
    private func findCachedPrayer(
        type: PrayerType,
        date: Date,
        settingsHash: String
    ) async throws -> CachedPrayerDomain? {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        let typeRaw = type.rawValue
        
        let predicate = #Predicate<CachedPrayer> { prayer in
            prayer.prayerType == typeRaw &&
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
        content: [PrayerTextItem],
        settingsHash: String,
        nusach: String? = nil
    ) async throws {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        
        // Delete existing cache entry for this prayer
        let typeRaw = type.rawValue
        let deletePredicate = #Predicate<CachedPrayer> { prayer in
            prayer.prayerType == typeRaw &&
            prayer.date >= startOfDay &&
            prayer.date < endOfDay &&
            prayer.settingsHash == settingsHash
        }
        let deleteDescriptor = FetchDescriptor<CachedPrayer>(predicate: deletePredicate)
        let existingPrayers = try modelContext.fetch(deleteDescriptor)
        for prayer in existingPrayers {
            modelContext.delete(prayer)
        }
        
        // Encode items as JSON string
        let encoder = JSONEncoder()
        let contentData = try encoder.encode(content)
        guard let contentString = String(data: contentData, encoding: .utf8) else {
            throw CacheError.encodingFailed
        }
        
        // Create new cache entry
        let cachedPrayer = CachedPrayer(
            prayerType: type.rawValue,
            date: startOfDay,
            nusach: nusach ?? "edot",
            locationId: nil,
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
            let location = await getLocationInfo()
            let syncedSettings = await getSyncedSettings()
            let settings = PrayerSettings(from: localSettings, syncedSettings: syncedSettings)
            let nusach = syncedSettings.nusach.rawValue

            let response = try await prayerService.generatePrayer(
                type: type,
                date: date,
                nusach: nusach,
                location: location,
                tfilaMode: localSettings.tfilaMode.rawValue,
                settings: settings
            )

            try await cachePrayer(
                type: type,
                date: date,
                content: response.items,
                settingsHash: settingsHash,
                nusach: nusach
            )
            
            return try await findCachedPrayer(type: type, date: date, settingsHash: settingsHash)
        } catch {
            // Network failed - return nil
            return nil
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
}

// MARK: - Cache Statistics
struct CacheStatistics {
    let totalEntries: Int
    let validEntries: Int
    let expiredEntries: Int
    let totalSizeBytes: Int
    let lastRefreshDate: Date?
    
    var utilizationPercentage: Double {
        guard totalEntries > 0 else { return 0 }
        return Double(validEntries) / Double(totalEntries) * 100
    }
    
    var formattedSize: String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(totalSizeBytes))
    }
}

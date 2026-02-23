import Foundation
import Observation
import SwiftUI

@MainActor
@Observable
final class PrayerTextViewModel {
    // MARK: - State
    private(set) var loadingState: PrayerLoadingState = .idle
    private(set) var prayer: Prayer?
    private(set) var errorMessage: String?
    private(set) var isOffline = false
    
    // MARK: - UI State
    var showTableOfContents = false
    var currentScrollPosition: String?
    
    // MARK: - Parsed HTML Cache
    // Key is the stable PrayerSection.id (String), not DisplayablePrayerSection.id (UUID)
    private(set) var parsedSections: [String: AttributedString] = [:]
    
    // MARK: - Dependencies
    private let prayerService: PrayerService
    private let cacheService: PrayerCacheService?
    private let localSettings: LocalSettings
    private let locationRepository: LocationRepositoryProtocol
    private let getSyncedSettings: () async -> SyncedUserSettings
    
    // MARK: - Initialization
    init(prayerService: PrayerService, cacheService: PrayerCacheService?, localSettings: LocalSettings, locationRepository: LocationRepositoryProtocol, getSyncedSettings: @escaping () async -> SyncedUserSettings = { SyncedUserSettings.defaults }) {
        self.prayerService = prayerService
        self.cacheService = cacheService
        self.localSettings = localSettings
        self.locationRepository = locationRepository
        self.getSyncedSettings = getSyncedSettings
    }
    
    // MARK: - Public Methods
    func loadPrayer(_ prayer: Prayer) async {
        self.prayer = prayer
        loadingState = .loading
        errorMessage = nil
        isOffline = false
        
        // Try cache first if available
        if let cacheService = cacheService {
            do {
                if let cached = try await cacheService.getCachedPrayer(type: prayer.type, date: Date()) {
                    if let content = cached.content {
                        // Parse HTML content BEFORE updating UI state
                        parseHTMLContent(for: content)
                        loadingState = .loaded(content)
                        
                        // Check if cache was stale
                        if cached.isExpired {
                            // Trigger background refresh but don't block
                            Task {
                                await refreshPrayerFromNetwork(prayer)
                            }
                        }
                        return
                    }
                }
            } catch {
                // Cache lookup failed, continue to network
                print("Cache lookup failed: \(error)")
            }
        }
        
        // Fetch from network
        await refreshPrayerFromNetwork(prayer)
    }
    
    func refreshPrayer() async {
        guard let prayer = prayer else { return }
        
        // Clear local cache and force refresh
        await refreshPrayerFromNetwork(prayer)
    }
    
    // MARK: - Private Methods
    private func refreshPrayerFromNetwork(_ prayer: Prayer) async {
        do {
            // Get location info
            let location: PrayerLocationInfo
            if let selectedLoc = try? await locationRepository.getSelectedLocation() {
                location = PrayerLocationInfo(from: selectedLoc)
            } else {
                location = .defaultLocation
            }

            // Get synced settings (with fallback to defaults)
            let syncedSettings = await getSyncedSettings()
            let settings = PrayerSettings(from: localSettings, syncedSettings: syncedSettings)

            // Use synced nusach (from settings), not local string default
            let nusach = syncedSettings.nusach.rawValue

            let response = try await prayerService.generatePrayer(
                type: prayer.type,
                date: Date(),
                nusach: nusach,
                location: location,
                tfilaMode: localSettings.tfilaMode.rawValue,
                settings: settings
            )

            // Convert PrayerResponse items to PrayerText for rendering
            let prayerText = PrayerText(from: response.items)

            // Save to cache if available
            if let cacheService = cacheService {
                let settingsHash = SettingsHashGenerator.hash(
                    nusach: nusach,
                    locationId: localSettings.locationName,
                    tfilaMode: localSettings.tfilaMode.rawValue
                )
                try? await cacheService.savePrayer(
                    type: prayer.type,
                    date: Date(),
                    content: response.items,
                    settingsHash: settingsHash
                )
            }

            // Parse HTML content synchronously BEFORE updating UI state
            // (lightweight parser is fast enough - typically sub-millisecond per section)
            parseHTMLContent(for: prayerText)

            loadingState = .loaded(prayerText)
            isOffline = false

        } catch {
            errorMessage = error.localizedDescription
            loadingState = .error(error.localizedDescription)
            isOffline = true
        }
    }
    
    /// Parses HTML content for all sections using lightweight parser
    private func parseHTMLContent(for prayerText: PrayerText) {
        // Clear existing cache
        parsedSections.removeAll()
        
        // Parse each section's HTML using lightweight parser
        for section in prayerText.displayableSections {
            let html = section.content
            let attributedString = AttributedString.fromPrayerHTML(html, baseFontSize: 20)
            // Use the stable section.section.id (String) as the key
            parsedSections[section.section.id] = attributedString
        }
    }
    
    // MARK: - Table of Contents
    func toggleTableOfContents() {
        showTableOfContents.toggle()
    }
    
    func scrollToSection(_ sectionId: String) {
        currentScrollPosition = sectionId
        showTableOfContents = false
    }
    
    // MARK: - Computed Properties
    var prayerText: PrayerText? {
        if case .loaded(let text) = loadingState {
            return text
        }
        return nil
    }
    
    var isLoading: Bool {
        if case .loading = loadingState { return true }
        return false
    }
    
    var hasError: Bool {
        errorMessage != nil
    }
    
    var displayableSections: [DisplayablePrayerSection] {
        return prayerText?.displayableSections ?? []
    }
    
    var tableOfContentsItems: [TableOfContentsItem] {
        return prayerText?.tableOfContentsItems ?? []
    }
    
    var hasTableOfContents: Bool {
        return !(tableOfContentsItems.isEmpty)
    }
    
    var prayerTitle: String {
        return prayer?.hebrewName ?? ""
    }
    
    var prayerSubtitle: String {
        return prayer?.displayName ?? ""
    }
}

// MARK: - Prayer Text Display Helpers
extension PrayerTextViewModel {
    func sectionTitle(for section: DisplayablePrayerSection) -> String? {
        return section.title
    }
    
    func sectionContent(for section: DisplayablePrayerSection) -> String {
        return section.content
    }
    
    func parsedSectionContent(for section: DisplayablePrayerSection) -> AttributedString? {
        return parsedSections[section.section.id]
    }
    
    func isRepetitionSection(_ section: DisplayablePrayerSection) -> Bool {
        return section.isRepetition
    }
}

// MARK: - Font and Formatting
extension PrayerTextViewModel {
    var preferredFont: Font {
        // Use Dynamic Type for accessibility
        return .body
    }
    
    var textAlignment: TextAlignment {
        return .trailing // Hebrew is right-to-left
    }
    
    var textDirection: LayoutDirection {
        return .rightToLeft
    }
}

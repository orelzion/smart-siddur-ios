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
    
    // MARK: - Dependencies
    private let prayerService: PrayerService
    private let cacheService: PrayerCacheService?
    private let localSettings: LocalSettings
    
    // MARK: - Initialization
    init(prayerService: PrayerService, cacheService: PrayerCacheService?, localSettings: LocalSettings) {
        self.prayerService = prayerService
        self.cacheService = cacheService
        self.localSettings = localSettings
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
            let response = try await prayerService.generatePrayer(
                type: prayer.type,
                date: Date(),
                nusach: localSettings.nusachString,
                location: localSettings.locationName,
                tfilaMode: localSettings.tfilaMode == .regular ? "regular" : (localSettings.tfilaMode == .yahid ? "yahid" : "chazan")
            )
            
            // Save to cache if available
            if let cacheService = cacheService {
                // Generate settings hash and save prayer to cache
                let settingsHash = SettingsHashGenerator.hash(
                    nusach: localSettings.nusachString,
                    locationId: localSettings.locationName,
                    tfilaMode: localSettings.tfilaMode.rawValue
                )
                try? await cacheService.savePrayer(
                    type: prayer.type,
                    date: Date(),
                    content: response.prayer,
                    settingsHash: settingsHash
                )
            }
            
            loadingState = .loaded(response.prayer)
            isOffline = false
            
        } catch {
            errorMessage = error.localizedDescription
            loadingState = .error(error.localizedDescription)
            isOffline = true
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
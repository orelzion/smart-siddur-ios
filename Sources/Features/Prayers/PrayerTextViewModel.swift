import Foundation
import Observation

@MainActor
@Observable
final class PrayerTextViewModel {
    // MARK: - State
    private(set) var loadingState: PrayerLoadingState = .idle
    private(set) var prayer: Prayer?
    private(set) var errorMessage: String?
    
    // MARK: - UI State
    var showTableOfContents = false
    var currentScrollPosition: String?
    
    // MARK: - Dependencies
    private let prayerService: PrayerService
    private let localSettings: LocalSettings
    
    // MARK: - Cache
    private var cachedPrayerText: PrayerText?
    
    // MARK: - Initialization
    init(prayerService: PrayerService, localSettings: LocalSettings) {
        self.prayerService = prayerService
        self.localSettings = localSettings
    }
    
    // MARK: - Public Methods
    func loadPrayer(_ prayer: Prayer) async {
        self.prayer = prayer
        loadingState = .loading
        errorMessage = nil
        
        // Check cache first
        if let cachedText = cachedPrayerText {
            loadingState = .loaded(cachedText)
            return
        }
        
        do {
            let response = try await prayerService.generatePrayer(
                type: prayer.type,
                date: Date(),
                nusach: localSettings.nusach,
                location: localSettings.locationName,
                tfilaMode: localSettings.tfilaMode
            )
            
            // Cache the loaded prayer
            cachedPrayerText = response.prayer
            loadingState = .loaded(response.prayer)
            
        } catch {
            errorMessage = error.localizedDescription
            loadingState = .error(error.localizedDescription)
        }
    }
    
    func refreshPrayer() async {
        guard let prayer = prayer else { return }
        
        // Clear cache to force refresh
        cachedPrayerText = nil
        await loadPrayer(prayer)
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
    var preferredFont: UIFont {
        // Use Dynamic Type for accessibility
        return UIFont.preferredFont(forTextStyle: .body)
    }
    
    var textAlignment: NSTextAlignment {
        return .right // Hebrew is right-to-left
    }
    
    var textDirection: NSWritingDirection {
        return .rightToLeft
    }
}
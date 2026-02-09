import Foundation

// MARK: - Prayer Text Models
struct PrayerText: Codable {
    let sections: [PrayerSection]
    let metadata: TextMetadata
    
    struct PrayerSection: Codable, Identifiable {
        let id: String
        let title: String?
        let hebrewTitle: String?
        let content: String
        let order: Int
        
var displayTitle: String {
        if let hebrewTitle = hebrewTitle, !hebrewTitle.isEmpty {
            return hebrewTitle
        }
        if let title = title, !title.isEmpty {
            return title
        }
        return ""
    }
    }
    
    struct TextMetadata: Codable {
        let hasNikud: Bool
        let hasTeamim: Bool
        let language: String
        let textDirection: String
        let source: String
        
        init(hasNikud: Bool = true, hasTeamim: Bool = true, language: String = "hebrew", textDirection: String = "rtl", source: String = "generated") {
            self.hasNikud = hasNikud
            self.hasTeamim = hasTeamim
            self.language = language
            self.textDirection = textDirection
            self.source = source
        }
    }
}

// MARK: - Prayer Display Models
struct DisplayablePrayerSection: Identifiable {
    let id = UUID()
    let section: PrayerText.PrayerSection
    let isRepetition: Bool
    
    var title: String? {
        if isRepetition {
            return nil // Don't show title for repetitions
        }
        return section.displayTitle
    }
    
    var content: String {
        if isRepetition {
            return "(Repeat) \(section.content)"
        }
        return section.content
    }
}

// MARK: - Prayer Text Extensions
extension PrayerText {
    var displayableSections: [DisplayablePrayerSection] {
        return sections.enumerated().map { index, section in
            DisplayablePrayerSection(
                section: section,
                isRepetition: isRepetitionSection(section, at: index)
            )
        }
    }
    
    private func isRepetitionSection(_ section: PrayerText.PrayerSection, at index: Int) -> Bool {
        // Simple heuristic: if a section with the same title appeared before, mark as repetition
        let previousSections = sections.prefix(index)
        return previousSections.contains { $0.title == section.title || $0.hebrewTitle == section.hebrewTitle }
    }
    
    var tableOfContentsItems: [TableOfContentsItem] {
        return sections.compactMap { section in
            let title = section.displayTitle
            guard !title.isEmpty else { return nil }
            return TableOfContentsItem(
                id: section.id,
                title: title,
                order: section.order
            )
        }
    }
}

// MARK: - Table of Contents
struct TableOfContentsItem: Identifiable {
    let id: String
    let title: String
    let order: Int
}

// MARK: - Prayer Loading States
enum PrayerLoadingState: Equatable {
    case idle
    case loading
    case loaded(PrayerText)
    case error(String)
    
    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }
    
    var prayerText: PrayerText? {
        if case .loaded(let text) = self { return text }
        return nil
    }
    
    var errorMessage: String? {
        if case .error(let message) = self { return message }
        return nil
    }
    
    static func == (lhs: PrayerLoadingState, rhs: PrayerLoadingState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.loading, .loading):
            return true
        case (.loaded(let lhsText), .loaded(let rhsText)):
            return lhsText.sections.count == rhsText.sections.count
        case (.error(let lhsMessage), .error(let rhsMessage)):
            return lhsMessage == rhsMessage
        default:
            return false
        }
    }
}
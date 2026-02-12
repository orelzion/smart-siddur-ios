import Foundation
import SwiftUI

extension AttributedString {
    /// Parses simple HTML tags used in prayer text into an AttributedString
    /// Supports: <br>, <b>, <strong>, <small>, <font color="...">
    /// - Parameters:
    ///   - html: The HTML string to parse
    ///   - baseFontSize: The base font size for normal text (default: 20)
    /// - Returns: An AttributedString with proper formatting and colors
    static func fromPrayerHTML(_ html: String, baseFontSize: CGFloat = 20) -> AttributedString {
        var result = AttributedString()
        var currentText = ""
        var styleStack: [TextStyle] = [.default(baseFontSize)]
        var index = html.startIndex
        
        while index < html.endIndex {
            let char = html[index]
            
            if char == "<" {
                // Append any accumulated text with current style
                if !currentText.isEmpty {
                    result.append(createAttributedString(from: currentText, style: styleStack.last ?? .default(baseFontSize)))
                    currentText = ""
                }
                
                // Parse the tag
                if let (tag, endIndex) = parseTag(from: html, startingAt: index) {
                    index = endIndex
                    
                    switch tag {
                    case .br:
                        result.append(AttributedString("\n"))
                    case .openBold:
                        var newStyle = styleStack.last ?? .default(baseFontSize)
                        newStyle.isBold = true
                        styleStack.append(newStyle)
                    case .closeBold:
                        if styleStack.count > 1 {
                            styleStack.removeLast()
                        }
                    case .openSmall:
                        var newStyle = styleStack.last ?? .default(baseFontSize)
                        newStyle.isSmall = true
                        styleStack.append(newStyle)
                    case .closeSmall:
                        if styleStack.count > 1 {
                            styleStack.removeLast()
                        }
                    case .openFont(let color):
                        var newStyle = styleStack.last ?? .default(baseFontSize)
                        newStyle.color = color
                        styleStack.append(newStyle)
                    case .closeFont:
                        if styleStack.count > 1 {
                            styleStack.removeLast()
                        }
                    case .unknown:
                        break
                    }
                    continue
                }
            } else if char == "&" {
                // Handle HTML entities
                if let (entity, endIndex) = parseEntity(from: html, startingAt: index) {
                    currentText.append(entity)
                    index = endIndex
                    continue
                }
            }
            
            currentText.append(char)
            index = html.index(after: index)
        }
        
        // Append any remaining text
        if !currentText.isEmpty {
            result.append(createAttributedString(from: currentText, style: styleStack.last ?? .default(baseFontSize)))
        }
        
        return result
    }
    
    // MARK: - Helper Types
    
    private struct TextStyle {
        var baseFontSize: CGFloat
        var isBold: Bool = false
        var isSmall: Bool = false
        var color: Color? = nil
        
        static func `default`(_ baseFontSize: CGFloat) -> TextStyle {
            return TextStyle(baseFontSize: baseFontSize)
        }
        
        var fontSize: CGFloat {
            return isSmall ? baseFontSize * 0.75 : baseFontSize
        }
    }
    
    private enum HTMLTag {
        case br
        case openBold
        case closeBold
        case openSmall
        case closeSmall
        case openFont(Color)
        case closeFont
        case unknown
    }
    
    // MARK: - Parsing Helpers
    
    private static func parseTag(from html: String, startingAt index: String.Index) -> (HTMLTag, String.Index)? {
        guard html[index] == "<" else { return nil }
        
        var currentIndex = html.index(after: index)
        var tagContent = ""
        
        // Find the closing >
        while currentIndex < html.endIndex {
            let char = html[currentIndex]
            if char == ">" {
                // Found the end of tag
                let endIndex = html.index(after: currentIndex)
                let tag = parseTagContent(tagContent.trimmingCharacters(in: .whitespaces))
                return (tag, endIndex)
            }
            tagContent.append(char)
            currentIndex = html.index(after: currentIndex)
        }
        
        return nil
    }
    
    private static func parseTagContent(_ content: String) -> HTMLTag {
        let lowercased = content.lowercased()
        
        // Self-closing br
        if lowercased == "br" || lowercased == "br/" || lowercased == "br /" {
            return .br
        }
        
        // Bold tags
        if lowercased == "b" || lowercased == "strong" {
            return .openBold
        }
        if lowercased == "/b" || lowercased == "/strong" {
            return .closeBold
        }
        
        // Small tag
        if lowercased == "small" {
            return .openSmall
        }
        if lowercased == "/small" {
            return .closeSmall
        }
        
        // Font tag with color attribute
        if lowercased.hasPrefix("font") {
            if let color = extractColorAttribute(from: content) {
                return .openFont(color)
            }
            return .unknown
        }
        if lowercased == "/font" {
            return .closeFont
        }
        
        return .unknown
    }
    
    private static func extractColorAttribute(from tagContent: String) -> Color? {
        // Look for color="..." or color='...'
        let patterns = [
            #"color\s*=\s*"([^"]+)""#,
            #"color\s*=\s*'([^']+)'"#,
            #"color\s*=\s*([^\s>]+)"#
        ]
        
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
               let match = regex.firstMatch(in: tagContent, range: NSRange(tagContent.startIndex..., in: tagContent)),
               match.numberOfRanges > 1,
               let range = Range(match.range(at: 1), in: tagContent) {
                let colorString = String(tagContent[range]).trimmingCharacters(in: .whitespaces)
                return parseColor(colorString)
            }
        }
        
        return nil
    }
    
    private static func parseColor(_ colorString: String) -> Color? {
        let trimmed = colorString.trimmingCharacters(in: .whitespaces).lowercased()
        
        // Hex colors
        if trimmed.hasPrefix("#") {
            return Color(hex: trimmed)
        }
        
        // Named CSS colors
        switch trimmed {
        case "red": return .red
        case "blue": return .blue
        case "green": return .green
        case "orange": return .orange
        case "purple": return .purple
        case "yellow": return .yellow
        case "pink": return .pink
        case "gray", "grey": return .gray
        case "black": return .black
        case "white": return .white
        case "brown": return .brown
        case "cyan": return .cyan
        case "indigo": return .indigo
        case "mint": return .mint
        case "teal": return .teal
        default: return nil
        }
    }
    
    private static func parseEntity(from html: String, startingAt index: String.Index) -> (Character, String.Index)? {
        guard html[index] == "&" else { return nil }
        
        var currentIndex = html.index(after: index)
        var entityContent = ""
        
        // Look ahead up to 10 characters for the semicolon
        var lookAheadCount = 0
        while currentIndex < html.endIndex && lookAheadCount < 10 {
            let char = html[currentIndex]
            if char == ";" {
                // Found complete entity
                let endIndex = html.index(after: currentIndex)
                if let replacement = decodeEntity(entityContent) {
                    return (replacement, endIndex)
                }
                return nil
            }
            entityContent.append(char)
            currentIndex = html.index(after: currentIndex)
            lookAheadCount += 1
        }
        
        return nil
    }
    
    private static func decodeEntity(_ entity: String) -> Character? {
        switch entity {
        case "amp": return "&"
        case "lt": return "<"
        case "gt": return ">"
        case "nbsp": return "\u{00A0}" // non-breaking space
        case "quot": return "\""
        case "apos": return "'"
        default: return nil
        }
    }
    
    private static func createAttributedString(from text: String, style: TextStyle) -> AttributedString {
        var attrString = AttributedString(text)
        
        // Apply font with proper size and weight
        if style.isBold {
            attrString.font = .system(size: style.fontSize, weight: .bold)
        } else {
            attrString.font = .system(size: style.fontSize)
        }
        
        // Apply color if specified
        if let color = style.color {
            attrString.foregroundColor = color
        }
        
        return attrString
    }
}

// MARK: - Color Hex Initializer

extension Color {
    /// Creates a Color from a hex string (e.g., "#FF0000", "#F00", "#FF0000FF")
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        
        var int: UInt64 = 0
        guard Scanner(string: hex).scanHexInt64(&int) else { return nil }
        
        let r, g, b, a: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (r, g, b, a) = ((int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17, 255)
        case 6: // RGB (24-bit)
            (r, g, b, a) = (int >> 16, int >> 8 & 0xFF, int & 0xFF, 255)
        case 8: // RGBA (32-bit)
            (r, g, b, a) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

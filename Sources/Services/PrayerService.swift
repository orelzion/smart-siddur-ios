import Foundation
import Supabase

// MARK: - Prayer Service
@MainActor
final class PrayerService {
    private let supabase: SupabaseClient
    
    init(supabase: SupabaseClient) {
        self.supabase = supabase
    }
    
    // MARK: - Auth Header Helper
    /// Gets the current access token for Authorization header.
    /// supabase-swift's FunctionsClient.setAuth() is called asynchronously
    /// and may not fire before the first function invocation.
    private func authHeaders() async -> [String: String] {
        if let accessToken = try? await supabase.auth.session.accessToken {
            return ["Authorization": "Bearer \(accessToken)"]
        }
        return [:]
    }
    
    // MARK: - Generate Single Prayer
    func generatePrayer(
        type: PrayerType,
        date: Date = Date(),
        nusach: String,
        location: PrayerLocationInfo,
        tfilaMode: String,
        settings: PrayerSettings
    ) async throws -> PrayerResponse {
        let dateString = Self.formatDate(date)
        
        let request = PrayerRequest(
            prayerType: type.rawValue,
            date: dateString,
            nusach: nusach,
            tfilaMode: tfilaMode,
            location: location,
            settings: settings
        )
        
        do {
            let headers = await authHeaders()
            let response: PrayerResponse = try await supabase.functions.invoke(
                "generate-prayer",
                options: FunctionInvokeOptions(
                    headers: headers,
                    body: request
                )
            )
            return response
        } catch {
            throw PrayerError.generationFailed(error.localizedDescription)
        }
    }
    
    // MARK: - Generate Prayer Batch
    func generatePrayerBatch(
        prayerTypes: [PrayerType],
        startDate: Date,
        days: Int,
        nusach: String,
        location: PrayerLocationInfo,
        tfilaMode: String,
        settings: PrayerSettings
    ) async throws -> PrayerBatchResponse {
        let dateString = Self.formatDate(startDate)
        
        let request = PrayerBatchRequest(
            prayerTypes: prayerTypes.map { $0.rawValue },
            startDate: dateString,
            days: days,
            nusach: nusach,
            tfilaMode: tfilaMode,
            location: location,
            settings: settings
        )
        
        do {
            let headers = await authHeaders()
            let response: PrayerBatchResponse = try await supabase.functions.invoke(
                "generate-prayer-batch",
                options: FunctionInvokeOptions(
                    headers: headers,
                    body: request
                )
            )
            return response
        } catch {
            throw PrayerError.batchGenerationFailed(error.localizedDescription)
        }
    }
    
    // MARK: - Helpers
    
    /// Format date as YYYY-MM-DD for the backend
    private static func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = .current
        return formatter.string(from: date)
    }
    
    // Helper method to sort prayers by time of day
    func sortPrayersByTimeOfDay(_ prayers: [Prayer]) -> [Prayer] {
        return prayers.sorted { lhs, rhs in
            let lhsOrder = timeOfDayOrder(for: lhs.category)
            let rhsOrder = timeOfDayOrder(for: rhs.category)
            
            if lhsOrder != rhsOrder {
                return lhsOrder < rhsOrder
            }
            
            return lhs.displayName < rhs.displayName
        }
    }
    
    private func timeOfDayOrder(for category: PrayerCategory) -> Int {
        switch category {
        case .daily: return 0
        case .blessings: return 1
        case .special: return 2
        }
    }
}

// MARK: - Batch Request/Response Models (matches backend)
struct PrayerBatchRequest: Codable {
    let prayerTypes: [String]
    let startDate: String
    let days: Int
    let nusach: String
    let tfilaMode: String
    let location: PrayerLocationInfo
    let settings: PrayerSettings
    
    enum CodingKeys: String, CodingKey {
        case prayerTypes = "prayer_types"
        case startDate = "start_date"
        case days, nusach
        case tfilaMode = "tfila_mode"
        case location, settings
    }
}

struct PrayerBatchResponse: Codable {
    let prayers: [PrayerBatchEntry]
    let generatedAt: String
    let contentVersion: Int
    
    enum CodingKeys: String, CodingKey {
        case prayers
        case generatedAt = "generated_at"
        case contentVersion = "content_version"
    }
}

struct PrayerBatchEntry: Codable {
    let date: String
    let prayerType: String
    let items: [PrayerTextItem]
    let menu: [MenuEntry]
    let metadata: PrayerResponseMetadata
    
    enum CodingKeys: String, CodingKey {
        case date
        case prayerType = "prayer_type"
        case items, menu, metadata
    }
}

// MARK: - Prayer Errors
enum PrayerError: LocalizedError {
    case generationFailed(String)
    case batchGenerationFailed(String)
    case invalidRequest(String)
    case networkError(String)
    
    var errorDescription: String? {
        switch self {
        case .generationFailed(let message):
            return "Failed to generate prayer: \(message)"
        case .batchGenerationFailed(let message):
            return "Failed to generate prayer batch: \(message)"
        case .invalidRequest(let message):
            return "Invalid prayer request: \(message)"
        case .networkError(let message):
            return "Network error: \(message)"
        }
    }
}

import Foundation
import Supabase

// MARK: - Prayer Service
@MainActor
final class PrayerService {
    private let supabase: SupabaseClient
    
    init(supabase: SupabaseClient) {
        self.supabase = supabase
    }
    
    // MARK: - Generate Single Prayer
    func generatePrayer(
        type: PrayerType,
        date: Date = Date(),
        nusach: String,
        location: String? = nil,
        tfilaMode: String? = nil
    ) async throws -> PrayerResponse {
        let request = PrayerRequest(
            type: type,
            date: date,
            nusach: nusach,
            location: location,
            tfilaMode: tfilaMode
        )
        
        do {
            let response: PrayerResponse = try await supabase.functions.invoke(
                "generate-prayer",
                options: FunctionInvokeOptions(
                    body: try JSONEncoder().encode(request),
                    headers: ["Content-Type": "application/json"]
                )
            )
            return response
        } catch {
            throw PrayerError.generationFailed(error.localizedDescription)
        }
    }
    
    // MARK: - Generate Prayer Batch
    func generatePrayerBatch(
        from startDate: Date,
        to endDate: Date,
        nusach: String,
        location: String? = nil,
        tfilaMode: String? = nil
    ) async throws -> [PrayerResponse] {
        let request = PrayerBatchRequest(
            startDate: startDate,
            endDate: endDate,
            nusach: nusach,
            location: location,
            tfilaMode: tfilaMode
        )
        
        do {
            let response: PrayerBatchResponse = try await supabase.functions.invoke(
                "generate-prayer-batch",
                options: FunctionInvokeOptions(
                    body: try JSONEncoder().encode(request),
                    headers: ["Content-Type": "application/json"]
                )
            )
            return response.prayers
        } catch {
            throw PrayerError.batchGenerationFailed(error.localizedDescription)
        }
    }
    
    // MARK: - Get Today's Prayers
    func getTodaysPrayers(
        nusach: String,
        location: String? = nil,
        tfilaMode: String? = nil
    ) async throws -> [PrayerResponse] {
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        
        let todayPrayerTypes = PrayerType.allCases.filter { type in
            // For now, return all prayer types
            // In the future, this could be filtered based on calendar
            return true
        }
        
        var responses: [PrayerResponse] = []
        
        for type in todayPrayerTypes {
            do {
                let response = try await generatePrayer(
                    type: type,
                    date: today,
                    nusach: nusach,
                    location: location,
                    tfilaMode: tfilaMode
                )
                responses.append(response)
            } catch {
                // Log error but continue with other prayers
                print("Failed to generate prayer \(type.displayName): \(error)")
            }
        }
        
        return responses
    }
}

// MARK: - Batch Request/Response Models
struct PrayerBatchRequest: Codable {
    let startDate: Date
    let endDate: Date
    let nusach: String
    let location: String?
    let tfilaMode: String?
}

struct PrayerBatchResponse: Codable {
    let prayers: [PrayerResponse]
    let metadata: BatchMetadata
}

struct BatchMetadata: Codable {
    let generatedAt: Date
    let count: Int
    let dateRange: String
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

// MARK: - Prayer Service Extensions
extension PrayerService {
    // Helper method to check if a prayer is relevant for today
    private func isPrayerRelevantForToday(_ type: PrayerType, date: Date) -> Bool {
        // This would integrate with JewishCalendarService to determine
        // if a prayer is relevant for the current date (e.g., Hallel on Rosh Chodesh)
        // For now, return all prayers
        return true
    }
    
    // Helper method to sort prayers by time of day
    func sortPrayersByTimeOfDay(_ prayers: [Prayer]) -> [Prayer] {
        return prayers.sorted { lhs, rhs in
            let lhsOrder = timeOfDayOrder(for: lhs.category)
            let rhsOrder = timeOfDayOrder(for: rhs.category)
            
            if lhsOrder != rhsOrder {
                return lhsOrder < rhsOrder
            }
            
            // Within same category, sort by display name
            return lhs.displayName < rhs.displayName
        }
    }
    
    private func timeOfDayOrder(for category: PrayerCategory) -> Int {
        switch category {
        case .morning: return 0
        case .afternoon: return 1
        case .evening: return 2
        case .special: return 3
        }
    }
}
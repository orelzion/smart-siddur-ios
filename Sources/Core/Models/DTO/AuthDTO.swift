import Foundation

/// Auth-related Codable types for Supabase requests/responses.
/// Phase 2 will expand as needed.
enum AuthDTO {
    struct ProfileResponse: Codable, Sendable {
        let id: UUID
        let displayName: String?
        let email: String?
        let nusach: String?
        let isPremium: Bool

        enum CodingKeys: String, CodingKey {
            case id
            case displayName = "display_name"
            case email
            case nusach
            case isPremium = "is_premium"
        }
    }
}

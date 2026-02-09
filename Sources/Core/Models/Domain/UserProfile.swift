import Foundation

struct UserProfile: Codable, Identifiable, Sendable {
    let id: UUID
    var displayName: String?
    var email: String?
    var nusach: String?
    var isPremium: Bool

    init(id: UUID, displayName: String? = nil, email: String? = nil, nusach: String? = nil, isPremium: Bool = false) {
        self.id = id
        self.displayName = displayName
        self.email = email
        self.nusach = nusach
        self.isPremium = isPremium
    }
}

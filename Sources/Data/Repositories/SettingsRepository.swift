import Foundation
import Supabase

// MARK: - Protocol

/// Defines operations for synced user settings stored in Supabase.
protocol SettingsRepositoryProtocol: Sendable {
    /// Fetch the current user's synced settings from Supabase.
    func fetchSyncedSettings() async throws -> SyncedUserSettings
    /// Update the full synced settings object in Supabase.
    func updateSyncedSettings(_ settings: SyncedUserSettings) async throws
    /// Update a single column in user_settings without full object roundtrip.
    func updateSingleSetting(_ column: String, value: some Encodable & Sendable) async throws
}

// MARK: - Implementation

/// Concrete implementation wrapping Supabase user_settings table.
final class SettingsRepository: SettingsRepositoryProtocol, @unchecked Sendable {
    private let supabase: SupabaseClient

    init(supabase: SupabaseClient) {
        self.supabase = supabase
    }

    private var userId: UUID {
        get throws {
            guard let user = supabase.auth.currentUser else {
                throw SettingsError.notAuthenticated
            }
            return user.id
        }
    }

    func fetchSyncedSettings() async throws -> SyncedUserSettings {
        let uid = try userId
        let response: SyncedUserSettings = try await supabase
            .from("user_settings")
            .select()
            .eq("user_id", value: uid)
            .single()
            .execute()
            .value
        return response
    }

    func updateSyncedSettings(_ settings: SyncedUserSettings) async throws {
        let uid = try userId
        try await supabase
            .from("user_settings")
            .update(settings)
            .eq("user_id", value: uid)
            .execute()
    }

    func updateSingleSetting(_ column: String, value: some Encodable & Sendable) async throws {
        let uid = try userId
        try await supabase
            .from("user_settings")
            .update([column: value])
            .eq("user_id", value: uid)
            .execute()
    }
}

// MARK: - Errors

enum SettingsError: LocalizedError {
    case notAuthenticated

    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            "No authenticated user found. Please sign in."
        }
    }
}

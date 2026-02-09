import Foundation
import Observation

/// Local-only settings stored in UserDefaults.
/// Phase 2 (02-02) will flesh this out per MIGRATION_SPEC 7.2.
@MainActor
@Observable
final class LocalSettings {
    static let shared = LocalSettings()
    private let defaults = UserDefaults.standard
    private init() {}
}

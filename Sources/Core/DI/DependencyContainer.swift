import Foundation
import Observation
import Supabase

@Observable
final class DependencyContainer {
    let supabase: SupabaseClient

    init() {
        self.supabase = SupabaseConfig.client
    }
}

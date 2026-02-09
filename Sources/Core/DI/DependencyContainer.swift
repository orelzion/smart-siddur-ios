import Foundation
import Observation
import Supabase

@Observable
final class DependencyContainer {
    let supabase: SupabaseClient
    let authRepository: AuthRepository

    init() {
        self.supabase = SupabaseConfig.client
        self.authRepository = AuthRepository(supabase: SupabaseConfig.client)
    }
}

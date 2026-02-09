import Supabase
import Foundation

enum SupabaseConfig {
    static let url = URL(string: "https://dekdhfjyukihnggfftui.supabase.co")!
    static let anonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRla2RoZmp5dWtpaG5nZ2ZmdHVpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzA1NzEwODQsImV4cCI6MjA4NjE0NzA4NH0.3gOTqbrNEZHyaZ-56Zci-wwuyFitGdi0L4f4Rzk4-Vc"
    static let redirectURL = URL(string: "com.karriapps.smartsiddurlite://callback")!

    static let client = SupabaseClient(
        supabaseURL: url,
        supabaseKey: anonKey,
        options: .init(
            auth: .init(
                redirectToURL: redirectURL
            )
        )
    )
}

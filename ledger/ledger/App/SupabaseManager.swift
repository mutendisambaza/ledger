import Foundation
import Supabase

final class SupabaseManager {
    static let shared = SupabaseManager()

    let client: SupabaseClient?

    private init(bundle: Bundle = .main) {
        AppConfig.Supabase.assertConfigurationIsValid()

        guard
            let urlString = bundle.object(forInfoDictionaryKey: "SUPABASE_URL") as? String,
            let url = URL(string: urlString),
            let key = bundle.object(forInfoDictionaryKey: "SUPABASE_PUBLISHABLE_KEY") as? String,
            !key.isEmpty
        else {
            client = nil
            return
        }

        client = SupabaseClient(supabaseURL: url, supabaseKey: key)
    }
}

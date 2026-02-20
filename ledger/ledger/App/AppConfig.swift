//
//  AppConfig.swift
//  ledger
//
//  Created for Ledger Phase 1
//

import Foundation

enum AppConfig {
    static let appGroupId = "group.com.taurai.ledger"
    static let suiteName = appGroupId
    
    enum Keys {
        static let todayTotalCents = "today_total_cents"
        static let lastUpdated = "last_updated_iso"
        static let todayDate = "today_date_iso"
        static let transactions = "transactions_json"
    }
    
    enum Defaults {
        static let currency = "CAD"
        static let currencySymbol = "$"
    }
    
    // MARK: - Google OAuth Configuration
    // ⚠️ SECURITY NOTE: OAuth Client IDs for mobile apps are public by design.
    // However, if you need to change this, update it here.
    // For production, consider using environment variables or a secure config service.
    //
    // NOTE: Using Google Sign-In SDK (not custom URL schemes)
    // The SDK handles redirect URIs automatically via bundle identifiers
    enum GoogleOAuth {
        static let clientId = "879598092731-sn5unu43moo46vveb1gkeb002fdvaknt.apps.googleusercontent.com"
        static let authScope = "https://www.googleapis.com/auth/gmail.readonly"
    }
}

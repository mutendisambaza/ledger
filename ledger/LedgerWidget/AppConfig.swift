//
//  AppConfig.swift
//  LedgerWidget
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
        static let dailySpendLimitCents = "dailySpendLimitCents"
    }
    
    enum Defaults {
        static let currency = "CAD"
        static let currencySymbol = "$"
    }
}

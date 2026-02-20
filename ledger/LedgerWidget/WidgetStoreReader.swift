//
//  WidgetStoreReader.swift
//  LedgerWidget
//
//  Created for Ledger Phase 1
//

import Foundation

struct WidgetStoreReader {
    private let defaults: UserDefaults?
    
    init() {
        defaults = UserDefaults(suiteName: AppConfig.appGroupId)
    }
    
    var todayTotalCents: Int {
        defaults?.integer(forKey: AppConfig.Keys.todayTotalCents) ?? 0
    }
    
    var todayTotalFormatted: String {
        let dollars = Double(todayTotalCents) / 100.0
        return String(format: "\(AppConfig.Defaults.currencySymbol)%.2f", dollars)
    }
    
    var lastUpdated: Date? {
        guard let iso = defaults?.string(forKey: AppConfig.Keys.lastUpdated) else { return nil }
        return ISO8601DateFormatter().date(from: iso)
    }
    
    var isStale: Bool {
        guard let last = lastUpdated else { return true }
        return Calendar.current.isDateInToday(last) == false
    }
}


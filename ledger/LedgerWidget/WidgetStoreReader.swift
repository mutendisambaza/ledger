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

    var dailyLimitCents: Int {
        let configured = defaults?.integer(forKey: AppConfig.Keys.dailySpendLimitCents) ?? 0
        return configured > 0 ? configured : 5000
    }

    var budgetUsageRatio: Double {
        let limit = max(dailyLimitCents, 1)
        return min(1.0, max(0.0, Double(todayTotalCents) / Double(limit)))
    }

    var budgetUsagePercent: Int {
        Int((budgetUsageRatio * 100.0).rounded())
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

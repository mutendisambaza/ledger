//
//  SpendLimitManager.swift
//  ledger
//
//  Manages daily spending limit configuration and tracking
//

import Foundation
import Combine

class SpendLimitManager: ObservableObject {
    @Published var dailyLimitCents: Int {
        didSet {
            saveDailyLimit()
        }
    }

    private let userDefaults: UserDefaults
    private let limitKey = "dailySpendLimitCents"

    init(userDefaults: UserDefaults = UserDefaults(suiteName: AppConfig.appGroupId) ?? .standard) {
        self.userDefaults = userDefaults
        self.dailyLimitCents = userDefaults.integer(forKey: limitKey)

        // Set default limit if not configured ($50.00)
        if dailyLimitCents == 0 {
            dailyLimitCents = 5000
        }
    }

    /// Check if spending on a given date exceeded the daily limit
    func isDayOverLimit(date: Date, transactions: [Transaction]) -> Bool {
        let calendar = Calendar.current
        let dayStart = calendar.startOfDay(for: date)
        let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) ?? date

        let dayTotal = transactions
            .filter { $0.timestamp >= dayStart && $0.timestamp < dayEnd }
            .reduce(0) { $0 + $1.amountCents }

        return dayTotal > dailyLimitCents
    }

    /// Get total spending for a specific date
    func getTotalForDay(date: Date, transactions: [Transaction]) -> Int {
        let calendar = Calendar.current
        let dayStart = calendar.startOfDay(for: date)
        let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) ?? date

        return transactions
            .filter { $0.timestamp >= dayStart && $0.timestamp < dayEnd }
            .reduce(0) { $0 + $1.amountCents }
    }

    /// Save daily limit to UserDefaults
    private func saveDailyLimit() {
        userDefaults.set(dailyLimitCents, forKey: limitKey)
    }

    /// Format limit as currency string
    func formattedLimit() -> String {
        let dollars = Double(dailyLimitCents) / 100.0
        return String(format: "$%.2f", dollars)
    }

    /// Update limit from dollars
    func setLimitFromDollars(_ dollars: Double) {
        dailyLimitCents = Int(dollars * 100)
    }
}

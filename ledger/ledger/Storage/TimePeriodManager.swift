//
//  TimePeriodManager.swift
//  ledger
//
//  Manages time period selection and data caching
//

import Foundation
import Combine

enum TimePeriod: String, CaseIterable, Identifiable {
    case day = "Today"
    case twoDays = "2 Days"
    case week = "This Week"
    case month = "This Month"

    var id: String { rawValue }

    var days: Int {
        switch self {
        case .day: return 1
        case .twoDays: return 2
        case .week: return 7
        case .month: return 30
        }
    }
}

class TimePeriodManager: ObservableObject {
    @Published var selectedPeriod: TimePeriod = .day
    @Published private(set) var cachedData: [TimePeriod: [Transaction]] = [:]

    func getTransactions(for period: TimePeriod, from store: LedgerStore) -> [Transaction] {
        // Check cache first
        if let cached = cachedData[period] {
            return cached
        }

        // Calculate date range
        let calendar = Calendar.current
        let now = Date()
        let startOfToday = calendar.startOfDay(for: now)
        let startDate: Date
        switch period {
        case .day:
            startDate = startOfToday
        case .twoDays, .week, .month:
            startDate = calendar.date(byAdding: .day, value: -(period.days - 1), to: startOfToday) ?? startOfToday
        }

        // Filter transactions
        let filtered = store.transactions.filter { transaction in
            transaction.timestamp >= startDate && transaction.timestamp <= now
        }

        // Cache the result
        cachedData[period] = filtered

        return filtered
    }

    func getTotalCents(for period: TimePeriod, from store: LedgerStore) -> Int {
        let transactions = getTransactions(for: period, from: store)
        return transactions.reduce(0) { $0 + $1.amountCents }
    }

    func invalidateCache() {
        cachedData.removeAll()
    }

    func invalidateCache(for period: TimePeriod) {
        cachedData[period] = nil
    }
}

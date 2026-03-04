//
//  Models.swift
//  ledger
//
//  Created for Ledger Phase 1
//

import Foundation

struct Transaction: Codable, Identifiable, Equatable {
    let id: UUID
    let emailMessageId: String
    let merchant: String
    let amountCents: Int
    let currency: String
    let timestamp: Date
    let subject: String
    let confidence: Double // 0.0 - 1.0
    
    var amountFormatted: String {
        let dollars = Double(amountCents) / 100.0
        let symbol = AppConfig.Defaults.symbol(for: currency)
        return String(format: "\(symbol)%.2f", dollars)
    }
}

struct DailySummary: Codable {
    let date: String // YYYY-MM-DD
    let totalCents: Int
    let transactionCount: Int
    let lastUpdated: Date
    
    var totalFormatted: String {
        let dollars = Double(totalCents) / 100.0
        let symbol = AppConfig.Defaults.currentCurrencySymbol()
        return String(format: "\(symbol)%.2f", dollars)
    }
}

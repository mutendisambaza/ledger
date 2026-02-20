//
//  LedgerStore.swift
//  ledger
//
//  Created for Ledger Phase 1
//

import Foundation
import Combine
import WidgetKit

final class LedgerStore: ObservableObject {
    static let shared = LedgerStore()
    
    @Published private(set) var transactions: [Transaction] = []
    @Published private(set) var todaySummary: DailySummary
    
    private let userDefaults: UserDefaults?
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    private init() {
        userDefaults = UserDefaults(suiteName: AppConfig.suiteName)
        
        // Initialize with empty today summary
        let today = Calendar.current.startOfDay(for: Date())
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: today)
        
        todaySummary = DailySummary(
            date: dateString,
            totalCents: 0,
            transactionCount: 0,
            lastUpdated: Date()
        )
        
        load()
    }
    
    // MARK: - Core Operations
    
    func addTransaction(_ tx: Transaction) -> Bool {
        // Check for duplicates by emailMessageId
        if transactions.contains(where: { $0.emailMessageId == tx.emailMessageId }) {
            return false
        }
        
        transactions.append(tx)
        updateTodaySummary()
        save()
        syncToWidget()
        return true
    }
    
    func addTransactions(_ txs: [Transaction]) -> Int {
        var added = 0
        for tx in txs {
            if addTransaction(tx) {
                added += 1
            }
        }
        return added
    }
    
    func getTransactions(for date: Date?) -> [Transaction] {
        guard let date = date else {
            return transactions
        }
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            // Fallback: if date calculation fails, return empty array
            return []
        }
        
        return transactions.filter { tx in
            tx.timestamp >= startOfDay && tx.timestamp < endOfDay
        }
    }
    
    func getTodayTotal() -> Int {
        return todaySummary.totalCents
    }
    
    func clearAll() {
        transactions.removeAll()
        updateTodaySummary()
        save()
        syncToWidget()
    }
    
    // MARK: - Private Helpers
    
    private func updateTodaySummary() {
        let today = Calendar.current.startOfDay(for: Date())
        let todayTransactions = getTransactions(for: today)
        let total = todayTransactions.reduce(0) { $0 + $1.amountCents }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: today)
        
        todaySummary = DailySummary(
            date: dateString,
            totalCents: total,
            transactionCount: todayTransactions.count,
            lastUpdated: Date()
        )
    }
    
    // MARK: - Persistence
    
    private func save() {
        guard let defaults = userDefaults else { return }
        
        do {
            let data = try encoder.encode(transactions)
            defaults.set(data, forKey: AppConfig.Keys.transactions)
        } catch {
            print("Failed to save transactions: \(error)")
        }
    }
    
    private func load() {
        guard let defaults = userDefaults else { return }
        
        guard let data = defaults.data(forKey: AppConfig.Keys.transactions) else {
            return
        }
        
        do {
            transactions = try decoder.decode([Transaction].self, from: data)
            updateTodaySummary()
        } catch {
            print("Failed to load transactions: \(error)")
        }
    }
    
    // MARK: - Widget Sync
    
    func syncToWidget() {
        guard let defaults = userDefaults else { return }
        
        // Update today summary first
        updateTodaySummary()
        
        // Write widget keys
        defaults.set(todaySummary.totalCents, forKey: AppConfig.Keys.todayTotalCents)
        
        let dateFormatter = ISO8601DateFormatter()
        defaults.set(dateFormatter.string(from: todaySummary.lastUpdated), forKey: AppConfig.Keys.lastUpdated)
        defaults.set(todaySummary.date, forKey: AppConfig.Keys.todayDate)
        
        // Reload widget timelines
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    // MARK: - Gmail Sync
    
    func syncFromGmail(gmailClient: GmailClient, parser: ReceiptParser) async throws -> SyncResult {
        var messagesScanned = 0
        var transactionsAdded = 0
        var errors: [String] = []
        
        do {
            let messages = try await gmailClient.getRecentReceipts()
            messagesScanned = messages.count
            
            var newTransactions: [Transaction] = []
            
            for message in messages {
                // Check if we already have this message
                if transactions.contains(where: { $0.emailMessageId == message.id }) {
                    continue
                }
                
                // Parse the receipt
                guard let parsed = parser.parse(message: message) else {
                    continue
                }
                
                // Only add if confidence is above threshold
                guard parsed.confidence > 0.3 else {
                    continue
                }
                
                // Create transaction
                let transaction = Transaction(
                    id: UUID(),
                    emailMessageId: message.id,
                    merchant: parsed.merchant,
                    amountCents: parsed.amountCents,
                    currency: parsed.currency,
                    timestamp: message.date,
                    subject: message.subject,
                    confidence: parsed.confidence
                )
                
                newTransactions.append(transaction)
            }
            
            // Add all new transactions
            transactionsAdded = addTransactions(newTransactions)
            
        } catch {
            errors.append("Sync failed: \(error.localizedDescription)")
        }
        
        return SyncResult(
            messagesScanned: messagesScanned,
            transactionsAdded: transactionsAdded,
            errors: errors
        )
    }
}

struct SyncResult {
    let messagesScanned: Int
    let transactionsAdded: Int
    let errors: [String]
}


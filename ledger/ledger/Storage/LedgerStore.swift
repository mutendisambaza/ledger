//
//  LedgerStore.swift
//  ledger
//
//  Created for Ledger Phase 1
//

import Foundation
import Combine
import UIKit
import WidgetKit

final class LedgerStore: ObservableObject {
    static let shared = LedgerStore()

    enum SyncStatus {
        case idle
        case syncing
        case success(GmailSyncResult)
        case failed(Error)
    }

    @Published private(set) var transactions: [Transaction] = []
    @Published private(set) var todaySummary: DailySummary
    @Published private(set) var syncStatus: SyncStatus = .idle

    private let userDefaults: UserDefaults?
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let notificationCenter: NotificationCenter
    private var foregroundObserver: NSObjectProtocol?
    private var lastSyncDependencies: (gmailClient: GmailClient, parser: ReceiptParser)?

    private enum Storage {
        static let schemaVersion = "storage_schema_version"
        static let pendingSync = "pending_sync"
        static let hasEverSynced = "has_ever_synced"
        static let lastSuccessfulSyncAt = "last_successful_sync_at"
    }

    init(
        userDefaults: UserDefaults? = UserDefaults(suiteName: AppConfig.suiteName),
        notificationCenter: NotificationCenter = .default
    ) {
        self.userDefaults = userDefaults
        self.notificationCenter = notificationCenter

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

        runMigrationsIfNeeded()
        load()
        registerForegroundObserver()
    }

    deinit {
        if let observer = foregroundObserver {
            notificationCenter.removeObserver(observer)
        }
    }

    // MARK: - Core Operations

    func addTransaction(_ tx: Transaction) -> Bool {
        addTransaction(tx, syncWidget: true)
    }

    private func addTransaction(_ tx: Transaction, syncWidget: Bool) -> Bool {
        // Check for duplicates by emailMessageId
        if transactions.contains(where: { $0.emailMessageId == tx.emailMessageId }) {
            return false
        }
        
        transactions.append(tx)
        updateTodaySummary()
        save()
        if syncWidget {
            syncToWidget()
        }
        return true
    }
    
    func addTransactions(_ txs: [Transaction]) -> Int {
        var added = 0
        for tx in txs {
            if addTransaction(tx, syncWidget: false) {
                added += 1
            }
        }
        syncToWidget()
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

    var hasEverSynced: Bool {
        userDefaults?.bool(forKey: Storage.hasEverSynced) ?? false
    }

    func clearAll() {
        clearAllData()
    }

    /// Clears all persisted transactions and widget/App Group state.
    func clearAllData() {
        guard let defaults = userDefaults else { return }

        transactions.removeAll()
        syncStatus = .idle
        updateTodaySummary()

        defaults.removeObject(forKey: AppConfig.Keys.transactions)
        defaults.removeObject(forKey: AppConfig.Keys.todayTotalCents)
        defaults.removeObject(forKey: AppConfig.Keys.lastUpdated)
        defaults.removeObject(forKey: AppConfig.Keys.todayDate)
        defaults.set(0, forKey: Storage.schemaVersion)
        defaults.removeObject(forKey: Storage.pendingSync)
        defaults.removeObject(forKey: Storage.hasEverSynced)
        defaults.removeObject(forKey: Storage.lastSuccessfulSyncAt)

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

    private func registerForegroundObserver() {
        foregroundObserver = notificationCenter.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            Task { await self.retryPendingSyncIfNeeded() }
        }
    }

    private func retryPendingSyncIfNeeded() async {
        guard let defaults = userDefaults,
              defaults.bool(forKey: Storage.pendingSync),
              let dependencies = lastSyncDependencies else {
            return
        }

        _ = await syncFromGmail(
            gmailClient: dependencies.gmailClient,
            parser: dependencies.parser
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

    private func runMigrationsIfNeeded() {
        guard let defaults = userDefaults else { return }
        let currentVersion = defaults.integer(forKey: Storage.schemaVersion)
        let targetVersion = 1

        guard currentVersion < targetVersion else { return }

        if let existing = defaults.data(forKey: AppConfig.Keys.transactions) {
            let migrated = Self.migrate(data: existing, from: currentVersion, to: targetVersion)
            defaults.set(migrated, forKey: AppConfig.Keys.transactions)
        }
        defaults.set(targetVersion, forKey: Storage.schemaVersion)
    }

    /// Migrates serialized transaction payloads across schema versions.
    /// - Parameters:
    ///   - data: Raw persisted transaction JSON data.
    ///   - from: Existing schema version.
    ///   - to: Target schema version.
    /// - Returns: Migrated JSON data, or original data on failure.
    static func migrate(data: Data, from: Int, to: Int) -> Data {
        guard from < to else { return data }

        // v1 migration is intentionally a no-op re-encode to guarantee shape stability.
        do {
            let decoded = try JSONDecoder().decode([Transaction].self, from: data)
            return try JSONEncoder().encode(decoded)
        } catch {
            return data
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

    /// Syncs inbox receipts and updates sync status for UI feedback.
    /// - Parameters:
    ///   - gmailClient: Gmail API client.
    ///   - parser: Deterministic receipt parser.
    ///   - fetchWindowDays: Number of days to fetch, clamped in `GmailClient`.
    /// - Returns: Aggregated sync result.
    @discardableResult
    @MainActor
    func syncFromGmail(
        gmailClient: GmailClient,
        parser: ReceiptParser,
        fetchWindowDays: Int = 7
    ) async -> GmailSyncResult {
        lastSyncDependencies = (gmailClient, parser)
        syncStatus = .syncing

        do {
            let now = Date()
            let lastSuccessfulSync = userDefaults?.object(forKey: Storage.lastSuccessfulSyncAt) as? Date
            let (messages, fetchResult) = try await gmailClient.getRecentReceipts(
                fetchWindowDays: fetchWindowDays,
                sinceDate: lastSuccessfulSync,
                untilDate: now
            )

            var parsedCount = 0
            var inserted = 0
            var skipped = fetchResult.skipped
            let errors = fetchResult.errors
            var newTransactions: [Transaction] = []

            for message in messages {
                // Check if we already have this message
                if transactions.contains(where: { $0.emailMessageId == message.id }) {
                    skipped += 1
                    continue
                }

                // Parse the receipt
                guard let parsedReceipt = parser.parse(message: message) else {
                    skipped += 1
                    continue
                }

                // Only add if confidence is above threshold
                guard parsedReceipt.confidence >= 0.3 else {
                    skipped += 1
                    continue
                }
                parsedCount += 1

                // Create transaction
                let transaction = Transaction(
                    id: UUID(),
                    emailMessageId: message.id,
                    merchant: parsedReceipt.merchant,
                    amountCents: parsedReceipt.amountCents,
                    currency: parsedReceipt.currency,
                    timestamp: message.date,
                    subject: message.subject,
                    confidence: parsedReceipt.confidence
                )

                newTransactions.append(transaction)
            }

            // Add all new transactions
            inserted = addTransactions(newTransactions)
            userDefaults?.set(false, forKey: Storage.pendingSync)
            userDefaults?.set(true, forKey: Storage.hasEverSynced)
            userDefaults?.set(now, forKey: Storage.lastSuccessfulSyncAt)

            let result = GmailSyncResult(
                fetched: fetchResult.fetched,
                parsed: parsedCount,
                inserted: inserted,
                skipped: skipped,
                errors: errors
            )
            syncStatus = .success(result)
            return result
        } catch {
            let errorMessage = "Sync failed: \(error.localizedDescription)"
            if isNetworkError(error) {
                userDefaults?.set(true, forKey: Storage.pendingSync)
            }

            syncStatus = .failed(error)
            return GmailSyncResult(
                fetched: 0,
                parsed: 0,
                inserted: 0,
                skipped: 0,
                errors: [errorMessage]
            )
        }

    }

    private func isNetworkError(_ error: Error) -> Bool {
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost, .timedOut, .cannotFindHost, .cannotConnectToHost, .dnsLookupFailed:
                return true
            default:
                return false
            }
        }
        return false
    }
}

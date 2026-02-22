import XCTest
@testable import ledger

final class LedgerStoreTests: XCTestCase {
    private var defaults: UserDefaults!
    private var suiteName: String!

    override func setUp() {
        super.setUp()
        suiteName = "LedgerStoreTests-\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)
        defaults.removePersistentDomain(forName: suiteName)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        defaults = nil
        suiteName = nil
        super.tearDown()
    }

    func testMigrationBumpsSchemaVersionAndLoadsTransactions() throws {
        let legacyTransactions = [makeTransaction(emailID: "m-1", amount: 1234)]
        let data = try JSONEncoder().encode(legacyTransactions)
        defaults.set(data, forKey: AppConfig.Keys.transactions)
        defaults.set(0, forKey: "storage_schema_version")

        let store = LedgerStore(userDefaults: defaults, notificationCenter: .default)

        XCTAssertEqual(defaults.integer(forKey: "storage_schema_version"), 1)
        XCTAssertEqual(store.transactions.count, 1)
        XCTAssertEqual(store.transactions.first?.emailMessageId, "m-1")
    }

    func testMigrateIsNoOpForCurrentVersion() throws {
        let transactions = [makeTransaction(emailID: "m-2", amount: 500)]
        let encoded = try JSONEncoder().encode(transactions)

        let migrated = LedgerStore.migrate(data: encoded, from: 1, to: 1)
        let decoded = try JSONDecoder().decode([Transaction].self, from: migrated)

        XCTAssertEqual(decoded, transactions)
    }

    func testAddTransactionDeduplicatesByEmailMessageID() {
        let store = LedgerStore(userDefaults: defaults, notificationCenter: .default)

        let first = makeTransaction(emailID: "dup-1", amount: 100)
        let duplicate = makeTransaction(emailID: "dup-1", amount: 200)

        XCTAssertTrue(store.addTransaction(first))
        XCTAssertFalse(store.addTransaction(duplicate))
        XCTAssertEqual(store.transactions.count, 1)
    }

    func testAddTransactionsSyncsWidgetKeys() {
        let store = LedgerStore(userDefaults: defaults, notificationCenter: .default)

        let now = Date()
        let txA = makeTransaction(emailID: "a", amount: 1000, timestamp: now)
        let txB = makeTransaction(emailID: "b", amount: 2500, timestamp: now)

        _ = store.addTransactions([txA, txB])

        XCTAssertEqual(defaults.integer(forKey: AppConfig.Keys.todayTotalCents), 3500)
        XCTAssertNotNil(defaults.string(forKey: AppConfig.Keys.todayDate))
        XCTAssertNotNil(defaults.string(forKey: AppConfig.Keys.lastUpdated))
    }

    private func makeTransaction(emailID: String, amount: Int, timestamp: Date = Date()) -> Transaction {
        Transaction(
            id: UUID(),
            emailMessageId: emailID,
            merchant: "Test",
            amountCents: amount,
            currency: "USD",
            timestamp: timestamp,
            subject: "Receipt",
            confidence: 0.9
        )
    }
}

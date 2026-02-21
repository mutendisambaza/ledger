//
//  HomeView.swift
//  ledger
//
//  Modern home view with glassmorphism and time period management
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var store: LedgerStore
    @EnvironmentObject var router: NavigationRouter
    @ObservedObject var authManager: GoogleAuthManager

    @StateObject private var periodManager = TimePeriodManager()
    private let insightEngine = InsightEngine()

    @State private var showSettings = false
    @State private var hiddenTransactionIDs: Set<UUID> = []
    @State private var previousTransactionIDs: Set<UUID> = []
    @State private var newlyInsertedIDs: Set<UUID> = []

    @State private var showSuccessToast = false
    @State private var successMessage = ""
    @State private var showFailureBanner = false
    @State private var failureMessage = ""
    @State private var showInitialSyncOverlay = false

    private var gmailClient: GmailClient {
        GmailClient(authManager: authManager)
    }

    private var parser: ReceiptParser {
        ReceiptParser()
    }

    private var visibleCurrentPeriodTransactions: [Transaction] {
        currentPeriodTransactions
            .filter { !hiddenTransactionIDs.contains($0.id) }
            .sorted { $0.timestamp > $1.timestamp }
    }

    private var currentPeriodTransactions: [Transaction] {
        periodManager.getTransactions(for: periodManager.selectedPeriod, from: store)
    }

    private var currentPeriodTotal: Int {
        periodManager.getTotalCents(for: periodManager.selectedPeriod, from: store)
    }

    private var currentInsight: Insight? {
        insightEngine.generateInsight(
            transactions: visibleCurrentPeriodTransactions,
            todayTotalCents: currentPeriodTotal
        )
    }

    private var isSyncing: Bool {
        if case .syncing = store.syncStatus {
            return true
        }
        return false
    }

    var body: some View {
        ZStack {
            // Background
            DesignSystem.Colors.black
                .ignoresSafeArea()

            ScrollView {
                mainContent
            }

            if showInitialSyncOverlay {
                DesignSystem.Colors.black.opacity(0.65)
                    .ignoresSafeArea()
                VStack(spacing: DesignSystem.Spacing.xs) {
                    ProgressView()
                        .tint(DesignSystem.Colors.sageGreen)
                    Text("Finding your receipts…")
                        .font(DesignSystem.Typography.body)
                        .foregroundColor(DesignSystem.Colors.glowingWhite)
                }
                .padding(DesignSystem.Spacing.md)
                .background(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                        .fill(DesignSystem.Colors.black.opacity(0.8))
                )
            }
        }
        .onSwipe(
            down: {
                router.showResting()
            },
            left: {
                router.showCalendar()
            }
        )
        .sheet(isPresented: $showSettings) {
            SettingsView(authManager: authManager, store: store)
        }
        .onAppear {
            previousTransactionIDs = Set(store.transactions.map(\.id))

            guard store.transactions.isEmpty, !store.hasEverSynced else { return }
            showInitialSyncOverlay = true

            Task {
                try? await Task.sleep(for: .seconds(1.5))
                await syncFromGmail()
                await MainActor.run {
                    showInitialSyncOverlay = false
                }
            }
        }
        .onChange(of: store.transactions) { _, newTransactions in
            let newIDs = Set(newTransactions.map(\.id))
            newlyInsertedIDs = newIDs.subtracting(previousTransactionIDs)
            previousTransactionIDs = newIDs
            periodManager.invalidateCache()

            Task {
                try? await Task.sleep(for: .seconds(2))
                await MainActor.run {
                    newlyInsertedIDs.removeAll()
                }
            }
        }
        .onReceive(store.$syncStatus) { newStatus in
            handleSyncStatus(newStatus)
        }
    }

    private var mainContent: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            headerSection

            TimePeriodToggle(periodManager: periodManager)
                .padding(.horizontal, DesignSystem.Spacing.md)

            periodTotalSection

            if let insight = currentInsight {
                InsightCard(insight: insight)
                    .padding(.horizontal, DesignSystem.Spacing.md)
            }

            if isSyncing {
                Text("Checking receipts…")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.chrome(0.8))
                    .transition(.opacity)
            }

            if showFailureBanner {
                failureBanner
            }

            transactionListSection
            syncSection
        }
    }

    private var headerSection: some View {
        HStack {
            Text("Ledger")
                .font(DesignSystem.Typography.sectionHeader)
                .foregroundColor(DesignSystem.Colors.glowingWhite)
                .glow(
                    color: DesignSystem.Colors.glowingWhite,
                    radius: DesignSystem.Effects.glowRadius
                )

            Spacer()

            Button(action: {
                showSettings = true
            }) {
                Image(systemName: "gearshape.fill")
                    .font(.system(size: 20))
                    .foregroundColor(DesignSystem.Colors.chromeSilver)
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.top, DesignSystem.Spacing.sm)
    }

    private var periodTotalSection: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            if currentPeriodTotal > 0 {
                AmountDisplay(
                    amountCents: currentPeriodTotal,
                    size: .hero,
                    glowColor: DesignSystem.Colors.sageGreen,
                    isPulsing: false
                )
                .accessibilityLabel("Total spent: \(formattedAmount(currentPeriodTotal))")
                .accessibilityAddTraits(.updatesFrequently)
            } else {
                PlaceholderAmount(size: .hero)
            }

            Text(periodManager.selectedPeriod.rawValue.lowercased())
                .font(DesignSystem.Typography.caption)
                .foregroundColor(DesignSystem.Colors.chrome(0.7))
        }
        .padding(.vertical, DesignSystem.Spacing.lg)
    }

    private var failureBanner: some View {
        HStack(spacing: DesignSystem.Spacing.xxs) {
            Text(failureMessage)
                .font(DesignSystem.Typography.caption)
                .foregroundColor(.white)

            Spacer()

            Button("Dismiss") {
                withAnimation(.ledgerSpring) {
                    showFailureBanner = false
                }
            }
            .font(DesignSystem.Typography.caption)
            .foregroundColor(.white)
        }
        .padding(DesignSystem.Spacing.sm)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                .fill(DesignSystem.Colors.failedRed)
        )
        .padding(.horizontal, DesignSystem.Spacing.md)
        .transition(.move(edge: .top).combined(with: .opacity))
    }

    private var transactionListSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            HStack {
                Text(periodManager.selectedPeriod.rawValue)
                    .font(DesignSystem.Typography.bodyMedium)
                    .foregroundColor(DesignSystem.Colors.chrome(0.8))
                Spacer()
                Text("\(visibleCurrentPeriodTransactions.count) transaction\(visibleCurrentPeriodTransactions.count == 1 ? "" : "s")")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.chrome(0.6))
            }
            .padding(.horizontal, DesignSystem.Spacing.md)

            if visibleCurrentPeriodTransactions.isEmpty {
                GlassCard {
                    EmptyStateView()
                }
                .padding(.horizontal, DesignSystem.Spacing.md)
            } else {
                GlassCard {
                    VStack(spacing: DesignSystem.Spacing.xs) {
                        ForEach(Array(visibleCurrentPeriodTransactions.enumerated()), id: \.element.id) { index, transaction in
                            transactionRow(index: index, transaction: transaction)
                            if index < visibleCurrentPeriodTransactions.count - 1 {
                                Divider()
                                    .background(DesignSystem.Colors.chrome(0.2))
                            }
                        }
                    }
                    .padding(DesignSystem.Spacing.sm)
                }
                .padding(.horizontal, DesignSystem.Spacing.md)
            }
        }
    }

    private var syncSection: some View {
        VStack(spacing: DesignSystem.Spacing.xxs) {
            GlassButton(
                isSyncing ? "Syncing..." : "Sync from Gmail",
                icon: "arrow.clockwise",
                style: .primary,
                action: { Task { await syncFromGmail() } }
            )
            .disabled(isSyncing)
            .padding(.horizontal, DesignSystem.Spacing.md)
            .shadow(
                color: isSyncing ? DesignSystem.Colors.sageGreen.opacity(0.65) : .clear,
                radius: isSyncing ? 16 : 0
            )
            .animation(Animation.glowPulse, value: isSyncing)
            .accessibilityLabel("Sync receipts from Gmail")
            .accessibilityHint("Checks your inbox for new receipts")

            if showSuccessToast {
                InsightCard(
                    insight: Insight(
                        type: .velocity,
                        message: successMessage
                    )
                )
                .padding(.horizontal, DesignSystem.Spacing.md)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
        .padding(.bottom, DesignSystem.Spacing.xl)
    }

    private func transactionRow(index: Int, transaction: Transaction) -> some View {
        TransactionRow(transaction: transaction, index: index)
            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                Button(role: .destructive) {
                    withAnimation(.pageSlide) {
                        _ = hiddenTransactionIDs.insert(transaction.id)
                    }
                } label: {
                    Text("Hide")
                }
            }
            .transition(.move(edge: .top).combined(with: .opacity))
            .animation(
                .pageSlide.delay(Double(index) * 0.08),
                value: newlyInsertedIDs.contains(where: { insertedID in
                    insertedID == transaction.id
                })
            )
    }

    private func formattedAmount(_ cents: Int) -> String {
        String(format: "$%.2f", Double(cents) / 100.0)
    }

    @MainActor
    private func syncFromGmail() async {
        guard !isSyncing else { return }
        _ = await store.syncFromGmail(gmailClient: gmailClient, parser: parser)
    }

    private func handleSyncStatus(_ status: LedgerStore.SyncStatus) {
        switch status {
        case .idle, .syncing:
            break
        case .success(let result):
            withAnimation(.ledgerSpring) {
                showFailureBanner = false
            }

            guard result.inserted > 0 else {
                return
            }

            successMessage = "Ledger found \(result.inserted) new transaction\(result.inserted == 1 ? "" : "s")"
            withAnimation(.ledgerSpring) {
                showSuccessToast = true
            }

            Task {
                try? await Task.sleep(for: .seconds(3))
                await MainActor.run {
                    withAnimation(.ledgerSpring) {
                        showSuccessToast = false
                    }
                }
            }
        case .failed:
            failureMessage = "Couldn't reach Gmail. Will retry."
            withAnimation(.ledgerSpring) {
                showFailureBanner = true
                showSuccessToast = false
            }
        }
    }
}

#Preview {
    HomeView(authManager: GoogleAuthManager())
        .environmentObject(NavigationRouter())
        .environmentObject(LedgerStore.shared)
}

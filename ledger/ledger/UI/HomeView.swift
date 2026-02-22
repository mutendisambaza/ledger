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
    @EnvironmentObject var prefs: UserPreferences
    @ObservedObject var authManager: GoogleAuthManager

    @StateObject private var periodManager = TimePeriodManager()
    private let insightEngine = InsightEngine()

    @State private var showSettings = false
    @State private var hiddenTransactionIDs: Set<UUID> = []
    @State private var previousTransactionIDs: Set<UUID> = []
    @State private var newlyInsertedIDs: Set<UUID> = []

    @State private var isAmountHidden = false
    @State private var showSuccessToast = false
    @State private var successMessage = ""
    @State private var showBalancedToast = false
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
                Color.black.opacity(0.55)
                    .ignoresSafeArea()

                VStack(spacing: DesignSystem.Spacing.xs) {
                    ProgressView()
                        .tint(DesignSystem.Colors.sageGreen)
                    Text("Ledger is finding your receipts…")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                }
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.vertical, DesignSystem.Spacing.sm)
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                            .fill(DesignSystem.Colors.surfaceElevated)
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                            .strokeBorder(DesignSystem.Colors.borderDefault, lineWidth: DesignSystem.Effects.borderWidth)
                    }
                )
            }

            // "Your Ledger is now Balanced" bottom toast
            VStack {
                Spacer()
                if showBalancedToast {
                    balancedToast
                }
            }
            .animation(.alertAppear, value: showBalancedToast)
            .ignoresSafeArea(.container, edges: .bottom)
        }
        .onSwipe(
            down: {
                router.showResting()
            }
            // Calendar accessible via header button — left-swipe reserved for period cycling on the amount
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
                Text("Ledger is checking your receipts…")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
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
                .foregroundColor(DesignSystem.Colors.primaryText)

            Spacer()

            HStack(spacing: DesignSystem.Spacing.sm) {
                Button(action: { router.showCalendar() }) {
                    Image(systemName: "calendar")
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                }

                Button(action: { showSettings = true }) {
                    Image(systemName: "gearshape")
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                }
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.top, DesignSystem.Spacing.sm)
    }

    private var periodTotalSection: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            Group {
                if isAmountHidden {
                    // Privacy mask — same hero size, dashes instead of digits
                    GlowingText(
                        text: "$--.--",
                        font: DesignSystem.Typography.heroAmount,
                        color: DesignSystem.Colors.secondaryText,
                        glowColor: DesignSystem.Colors.secondaryText,
                        isPulsing: false
                    )
                } else if currentPeriodTotal > 0 {
                    SlotAmountDisplay(
                        amountCents: currentPeriodTotal,
                        size: .hero,
                        glowColor: prefs.accent
                    )
                } else {
                    PlaceholderAmount(size: .hero)
                }
            }
            .animation(.stateToggle, value: isAmountHidden)

            Text(periodManager.selectedPeriod.rawValue.lowercased())
                .font(DesignSystem.Typography.caption)
                .foregroundColor(DesignSystem.Colors.chrome(0.7))
                .animation(.stateToggle, value: periodManager.selectedPeriod)
        }
        .padding(.vertical, DesignSystem.Spacing.lg)
        .contentShape(Rectangle())
        // Tap → toggle privacy mask
        .onTapGesture {
            withAnimation(.stateToggle) {
                isAmountHidden.toggle()
            }
        }
        // Swipe left → next period, swipe right → previous period
        .gesture(
            DragGesture(minimumDistance: 30, coordinateSpace: .local)
                .onEnded { value in
                    let isHorizontal = abs(value.translation.width) > abs(value.translation.height)
                    guard isHorizontal else { return }
                    if value.translation.width < 0 {
                        advancePeriod()
                    } else {
                        retreatPeriod()
                    }
                }
        )
    }

    private func advancePeriod() {
        let cases = TimePeriod.allCases
        guard let idx = cases.firstIndex(of: periodManager.selectedPeriod) else { return }
        withAnimation(.stateToggle) {
            periodManager.selectedPeriod = cases[(idx + 1) % cases.count]
        }
    }

    private func retreatPeriod() {
        let cases = TimePeriod.allCases
        guard let idx = cases.firstIndex(of: periodManager.selectedPeriod) else { return }
        withAnimation(.stateToggle) {
            periodManager.selectedPeriod = cases[idx == 0 ? cases.count - 1 : idx - 1]
        }
    }

    private var balancedToast: some View {
        HStack(spacing: DesignSystem.Spacing.xxs) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(prefs.accent)
            Text("Your Ledger is now Balanced")
                .font(DesignSystem.Typography.captionMedium)
                .foregroundColor(DesignSystem.Colors.primaryText)
        }
        .padding(.horizontal, DesignSystem.Spacing.sm)
        .padding(.vertical, DesignSystem.Spacing.xs)
        .background(
            ZStack {
                Capsule().fill(prefs.accent.opacity(0.12))
                Capsule().strokeBorder(prefs.accent.opacity(0.30), lineWidth: DesignSystem.Effects.borderWidth)
            }
        )
        .padding(.bottom, DesignSystem.Spacing.xl)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    private var failureBanner: some View {
        HStack(spacing: DesignSystem.Spacing.xxs) {
            Text(failureMessage)
                .font(DesignSystem.Typography.caption)
                .foregroundColor(DesignSystem.Colors.dangerColor)

            Spacer()

            Button("Dismiss") {
                withAnimation(.alertAppear) {
                    showFailureBanner = false
                }
            }
            .font(DesignSystem.Typography.captionMedium)
            .foregroundColor(DesignSystem.Colors.secondaryText)
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.xs)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                    .fill(DesignSystem.Colors.dangerColor.opacity(0.10))
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                    .strokeBorder(DesignSystem.Colors.dangerColor.opacity(0.22), lineWidth: DesignSystem.Effects.borderWidth)
            }
        )
        .padding(.horizontal, DesignSystem.Spacing.md)
        .transition(.move(edge: .top).combined(with: .opacity))
    }

    private var transactionListSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            HStack {
                Text(periodManager.selectedPeriod.rawValue)
                    .font(DesignSystem.Typography.captionMedium)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
                Spacer()
                Text("\(visibleCurrentPeriodTransactions.count) transaction\(visibleCurrentPeriodTransactions.count == 1 ? "" : "s")")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
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
                                    .background(DesignSystem.Colors.borderDefault)
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
        VStack(spacing: DesignSystem.Spacing.sm) {
            GlassButton(
                "Rebalance Ledger",
                icon: "arrow.clockwise",
                style: .primary,
                isLoading: isSyncing,
                loadingTitle: "Rebalancing…",
                action: { Task { await syncFromGmail() } }
            )
            .padding(.horizontal, DesignSystem.Spacing.md)
            .accessibilityLabel("Rebalance Ledger")
            .accessibilityHint("Checks your inbox for new transactions")

            if showSuccessToast {
                InsightCard(
                    insight: Insight(
                        type: .velocity,
                        message: successMessage
                    )
                )
                .padding(.horizontal, DesignSystem.Spacing.md)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .padding(.bottom, DesignSystem.Spacing.xl)
    }

    private func transactionRow(index: Int, transaction: Transaction) -> some View {
        TransactionRow(transaction: transaction, index: index)
            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                Button(role: .destructive) {
                    withAnimation(.stateToggle) {
                        _ = hiddenTransactionIDs.insert(transaction.id)
                    }
                } label: {
                    Text("Hide")
                }
            }
            // Slide from bottom, not top — content, not notification
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .animation(
                .listRow(index),
                value: newlyInsertedIDs.contains(where: { $0 == transaction.id })
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

            if result.inserted > 0 {
                successMessage = "Ledger found \(result.inserted) new transaction\(result.inserted == 1 ? "" : "s")"
                withAnimation(.ledgerSpring) {
                    showSuccessToast = true
                }
                Task {
                    try? await Task.sleep(for: .seconds(3))
                    await MainActor.run {
                        withAnimation(.ledgerSpring) { showSuccessToast = false }
                    }
                }
            } else {
                // No new transactions — Ledger is balanced
                withAnimation(.alertAppear) {
                    showBalancedToast = true
                }
                Task {
                    try? await Task.sleep(for: .seconds(3))
                    await MainActor.run {
                        withAnimation(.stateToggle) { showBalancedToast = false }
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
        .environmentObject(UserPreferences())
}

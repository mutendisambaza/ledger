//
//  HomeView.swift
//  ledger
//
//  Modern home view with glassmorphism and time period management
//

import SwiftUI
import Combine

struct HomeView: View {
    @EnvironmentObject var store: LedgerStore
    @EnvironmentObject var router: NavigationRouter
    @EnvironmentObject var prefs: UserPreferences
    @ObservedObject var authManager: GoogleAuthManager

    @StateObject private var periodManager = TimePeriodManager()
    @StateObject private var spendLimitManager = SpendLimitManager()
    private let insightEngine = InsightEngine()
    private let autoSyncTimer = Timer.publish(every: 600, on: .main, in: .common).autoconnect()

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
    @State private var selectedTopTab: HomeTopTab = .ledger
    @Namespace private var topTabNamespace

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
                await syncFromGmail(fetchWindowDays: 30)
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
        .onReceive(autoSyncTimer) { _ in
            guard authManager.isAuthenticated else { return }
            Task {
                await syncFromGmail(fetchWindowDays: 7)
            }
        }
    }

    private var mainContent: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            headerSection
            topNavigationSection
            tabContentSection
        }
    }

    private var topNavigationSection: some View {
        HStack(spacing: 8) {
            ForEach(HomeTopTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.pageSlide) {
                        selectedTopTab = tab
                    }
                } label: {
                    if selectedTopTab == tab {
                        Text(tab.title)
                            .font(.system(size: 12, weight: .semibold, design: .rounded))
                            .foregroundColor(navPillTextColor)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(
                                Capsule()
                                    .fill(navPillColor)
                                    .matchedGeometryEffect(id: "topNavPill", in: topTabNamespace)
                            )
                            .overlay(
                                Capsule()
                                    .stroke(navPillStrokeColor, lineWidth: 0.5)
                            )
                            .shadow(color: navPillColor.opacity(0.25), radius: 6, y: 2)
                    } else {
                        Circle()
                            .fill(navPillColor)
                            .frame(width: 8, height: 8)
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.top, 2)
    }

    private var navPillColor: Color {
        AppConfig.Defaults.isDarkMode()
            ? DesignSystem.Colors.glow(0.2)
            : Color.black.opacity(0.78)
    }

    private var navPillTextColor: Color {
        AppConfig.Defaults.isDarkMode()
            ? DesignSystem.Colors.glowingWhite
            : .white
    }

    private var navPillStrokeColor: Color {
        AppConfig.Defaults.isDarkMode()
            ? DesignSystem.Colors.glow(0.28)
            : Color.white.opacity(0.22)
    }

    @ViewBuilder
    private var tabContentSection: some View {
        Group {
            switch selectedTopTab {
            case .ledger:
                ledgerTabSection
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            case .timeline:
                timelineTabSection
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            case .goals:
                goalsTabSection
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .gesture(
            DragGesture(minimumDistance: 20)
                .onEnded { value in
                    guard abs(value.translation.width) > abs(value.translation.height) else { return }
                    let threshold: CGFloat = 40
                    if value.translation.width < -threshold {
                        selectAdjacentTab(direction: 1)
                    } else if value.translation.width > threshold {
                        selectAdjacentTab(direction: -1)
                    }
                }
        )
    }

    private func selectAdjacentTab(direction: Int) {
        let newIndex = max(0, min(HomeTopTab.allCases.count - 1, selectedTopTab.index + direction))
        guard let newTab = HomeTopTab(index: newIndex), newTab != selectedTopTab else { return }
        withAnimation(.pageSlide) {
            selectedTopTab = newTab
        }
    }

    private var ledgerTabSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
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

    private var timelineTabSection: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            GlassCard {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text("Timeline")
                        .font(DesignSystem.Typography.cardHeader)
                        .foregroundColor(DesignSystem.Colors.glowingWhite)
                    Text("Review spending patterns by day in your calendar timeline.")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.chrome(0.8))
                    GlassButton(
                        "Open Calendar",
                        icon: "calendar",
                        style: .secondary,
                        action: {
                            router.showCalendar()
                        }
                    )
                    .padding(.top, DesignSystem.Spacing.xxs)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xl))
            .padding(.horizontal, DesignSystem.Spacing.md)
            Spacer(minLength: DesignSystem.Spacing.xl)
        }
    }

    private var goalsTabSection: some View {
        let todayTotal = store.getTodayTotal()
        let limit = max(spendLimitManager.dailyLimitCents, 1)
        let progress = min(1.0, Double(todayTotal) / Double(limit))
        let percent = Int((progress * 100).rounded())

        return VStack(spacing: DesignSystem.Spacing.md) {
            GlassCard {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text("Daily Budget Goal")
                        .font(DesignSystem.Typography.cardHeader)
                        .foregroundColor(DesignSystem.Colors.glowingWhite)
                    Text("\(percent)% used")
                        .font(DesignSystem.Typography.sectionHeader)
                        .foregroundColor(DesignSystem.Colors.glowingWhite)
                    ProgressView(value: progress)
                        .tint(DesignSystem.Colors.accent)
                    Text("Used \(formattedAmount(todayTotal)) of \(spendLimitManager.formattedLimit())")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.chrome(0.78))
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xl))
            .padding(.horizontal, DesignSystem.Spacing.md)

            GlassCard {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text("Adjust Goal")
                        .font(DesignSystem.Typography.bodyMedium)
                        .foregroundColor(DesignSystem.Colors.glowingWhite)
                    Text("Use Settings to update your daily budget and widget target.")
                        .font(DesignSystem.Typography.caption)
                        .foregroundColor(DesignSystem.Colors.chrome(0.78))
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xl))
            .padding(.horizontal, DesignSystem.Spacing.md)
            Spacer(minLength: DesignSystem.Spacing.xl)
        }
    }

    private var headerSection: some View {
        HStack {
            Text("Ledger")
                .font(DesignSystem.Typography.bodyMedium)
                .foregroundColor(DesignSystem.Colors.glowingWhite)
                .glow(
                    color: DesignSystem.Colors.glowingWhite,
                    radius: DesignSystem.Effects.glowRadius
                )

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

            Text("Daily goal \(spendLimitManager.formattedLimit())")
                .font(DesignSystem.Typography.caption)
                .foregroundColor(DesignSystem.Colors.chrome(0.65))
        }
        .padding(.vertical, DesignSystem.Spacing.lg)
        .contentShape(Rectangle())
        .onTapGesture {
            router.reset(to: .splash)
        }
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
                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xl))
                .padding(.horizontal, DesignSystem.Spacing.md)
            }
        }
    }

    private var syncSection: some View {
        VStack(spacing: DesignSystem.Spacing.sm) {
            GlassButton(
                isSyncing ? "Rebalencing..." : "Rebalence",
                icon: "arrow.clockwise",
                style: .primary,
                isLoading: isSyncing,
                loadingTitle: "Rebalancing…",
                action: { Task { await syncFromGmail() } }
            )
            .padding(.horizontal, DesignSystem.Spacing.md)
            .shadow(
                color: isSyncing ? DesignSystem.Colors.sageGreen.opacity(0.65) : .clear,
                radius: isSyncing ? 16 : 0
            )
            .animation(.easeInOut(duration: 0.25), value: isSyncing)
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
        let symbol = AppConfig.Defaults.currentCurrencySymbol()
        return String(format: "\(symbol)%.2f", Double(cents) / 100.0)
    }

    @MainActor
    private func syncFromGmail(fetchWindowDays: Int = 7) async {
        guard !isSyncing else { return }
        _ = await store.syncFromGmail(
            gmailClient: gmailClient,
            parser: parser,
            fetchWindowDays: fetchWindowDays
        )
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

enum HomeTopTab: CaseIterable, Hashable {
    case ledger
    case timeline
    case goals

    var title: String {
        switch self {
        case .ledger: return "Ledger"
        case .timeline: return "Timeline"
        case .goals: return "Goals"
        }
    }

    var index: Int {
        switch self {
        case .ledger: return 0
        case .timeline: return 1
        case .goals: return 2
        }
    }

    init?(index: Int) {
        switch index {
        case 0: self = .ledger
        case 1: self = .timeline
        case 2: self = .goals
        default: return nil
        }
    }
}

#Preview {
    HomeView(authManager: GoogleAuthManager())
        .environmentObject(NavigationRouter())
        .environmentObject(LedgerStore.shared)
        .environmentObject(UserPreferences())
}

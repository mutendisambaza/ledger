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
    @State private var isSyncing = false
    @State private var lastSyncDate: Date?
    @State private var syncError: String?

    private var gmailClient: GmailClient {
        GmailClient(authManager: authManager)
    }

    private var parser: ReceiptParser {
        ReceiptParser()
    }

    private var currentPeriodTransactions: [Transaction] {
        periodManager.getTransactions(for: periodManager.selectedPeriod, from: store)
            .sorted { $0.timestamp > $1.timestamp }
    }

    private var currentPeriodTotal: Int {
        periodManager.getTotalCents(for: periodManager.selectedPeriod, from: store)
    }

    private var currentInsight: Insight? {
        insightEngine.generateInsight(
            transactions: currentPeriodTransactions,
            todayTotalCents: currentPeriodTotal
        )
    }
    
    var body: some View {
        ZStack {
            // Background
            DesignSystem.Colors.black
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: DesignSystem.Spacing.md) {
                    // Header with settings
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

                    // Time Period Toggle
                    TimePeriodToggle(periodManager: periodManager)
                        .padding(.horizontal, DesignSystem.Spacing.md)
                        .onChange(of: periodManager.selectedPeriod) { oldValue, newValue in
                            // Invalidate cache when switching away from a period
                            // to ensure fresh data on next selection
                        }

                    // Period Total (Hero)
                    VStack(spacing: DesignSystem.Spacing.xs) {
                        if currentPeriodTotal > 0 {
                            AmountDisplay(
                                amountCents: currentPeriodTotal,
                                size: .hero,
                                glowColor: DesignSystem.Colors.sageGreen,
                                isPulsing: false
                            )
                        } else {
                            PlaceholderAmount(size: .hero)
                        }

                        Text(periodManager.selectedPeriod.rawValue.lowercased())
                            .font(DesignSystem.Typography.caption)
                            .foregroundColor(DesignSystem.Colors.chrome(0.7))
                    }
                    .padding(.vertical, DesignSystem.Spacing.lg)

                    // Insight (conditional)
                    if let insight = currentInsight {
                        InsightCard(insight: insight)
                            .padding(.horizontal, DesignSystem.Spacing.md)
                    }

                    // Transaction List
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                        HStack {
                            Text(periodManager.selectedPeriod.rawValue)
                                .font(DesignSystem.Typography.bodyMedium)
                                .foregroundColor(DesignSystem.Colors.chrome(0.8))
                            Spacer()
                            Text("\(currentPeriodTransactions.count) transaction\(currentPeriodTransactions.count == 1 ? "" : "s")")
                                .font(DesignSystem.Typography.caption)
                                .foregroundColor(DesignSystem.Colors.chrome(0.6))
                        }
                        .padding(.horizontal, DesignSystem.Spacing.md)

                        if currentPeriodTransactions.isEmpty {
                            GlassCard {
                                EmptyStateView()
                            }
                            .padding(.horizontal, DesignSystem.Spacing.md)
                        } else {
                            GlassCard {
                                VStack(spacing: DesignSystem.Spacing.xs) {
                                    ForEach(Array(currentPeriodTransactions.enumerated()), id: \.element.id) { index, transaction in
                                        TransactionRow(transaction: transaction, index: index)

                                        if index < currentPeriodTransactions.count - 1 {
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

                    // Sync Button
                    VStack(spacing: DesignSystem.Spacing.xxs) {
                        GlassButton(
                            isSyncing ? "Syncing..." : "Sync from Gmail",
                            icon: "arrow.clockwise",
                            style: .primary,
                            action: syncFromGmail
                        )
                        .disabled(isSyncing)
                        .padding(.horizontal, DesignSystem.Spacing.md)

                        if let lastSync = lastSyncDate, !isSyncing {
                            Text("Last synced \(lastSync, style: .relative)")
                                .font(DesignSystem.Typography.caption)
                                .foregroundColor(DesignSystem.Colors.chrome(0.5))
                        }

                        if let error = syncError {
                            Text(error)
                                .font(DesignSystem.Typography.caption)
                                .foregroundColor(DesignSystem.Colors.failedRed)
                                .padding(.horizontal, DesignSystem.Spacing.md)
                        }
                    }
                    .padding(.bottom, DesignSystem.Spacing.xl)
                }
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
    }
    
    private func syncFromGmail() {
        guard !isSyncing else { return }

        isSyncing = true
        syncError = nil

        Task {
            do {
                let result = try await store.syncFromGmail(gmailClient: gmailClient, parser: parser)
                await MainActor.run {
                    lastSyncDate = Date()
                    isSyncing = false

                    // Invalidate cache to refresh data
                    periodManager.invalidateCache()

                    if !result.errors.isEmpty {
                        syncError = "\(result.errors.count) error(s) occurred"
                    }
                }
            } catch {
                await MainActor.run {
                    syncError = "Sync failed: \(error.localizedDescription)"
                    isSyncing = false
                }
            }
        }
    }
}

#Preview {
    HomeView(authManager: GoogleAuthManager())
        .environmentObject(NavigationRouter())
        .environmentObject(LedgerStore.shared)
}


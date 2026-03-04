//
//  RestingView.swift
//  ledger
//
//  Minimalist resting state - just the amount, swipe up to reveal app
//

import SwiftUI

struct RestingView: View {
    @ObservedObject var authManager: GoogleAuthManager
    @EnvironmentObject var router: NavigationRouter
    @EnvironmentObject var store: LedgerStore

    @State private var appeared = false
    @State private var hasTriggeredInitialSync = false

    private var isLoadingInitialAmount: Bool {
        store.getTodayTotal() == 0
            && !store.hasEverSynced
            && isSyncing
    }

    private var isSyncing: Bool {
        if case .syncing = store.syncStatus {
            return true
        }
        return false
    }

    var body: some View {
        ZStack {
            // Full-screen black background
            DesignSystem.Colors.black
                .ignoresSafeArea()

            // Centered amount
            VStack(spacing: DesignSystem.Spacing.lg) {
                Spacer()

                if store.getTodayTotal() > 0 {
                    AmountDisplay(
                        amountCents: store.getTodayTotal(),
                        size: .hero,
                        glowColor: DesignSystem.Colors.sageGreen,
                        isPulsing: true
                    )
                    .accessibilityLabel("Today's spending: \(formattedAmount(store.getTodayTotal()))")
                    .accessibilityAddTraits(.updatesFrequently)
                } else if isLoadingInitialAmount {
                    WaveLoadingAmount(size: .hero)
                        .accessibilityLabel("Loading today's spending")
                } else {
                    PlaceholderAmount(size: .hero)
                }

                Spacer()

                // Subtle hint
                Text("Swipe up")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.glow(0.3))
                    .opacity(appeared ? 0.5 : 0)
                    .padding(.bottom, DesignSystem.Spacing.xl)
            }
            .opacity(appeared ? 1 : 0)
        }
        .onSwipe(up: {
            router.showHome()
        })
        .onAppear {
            withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
                appeared = true
            }

            guard !hasTriggeredInitialSync,
                  store.transactions.isEmpty,
                  !store.hasEverSynced else {
                return
            }

            hasTriggeredInitialSync = true
            Task {
                _ = await store.syncFromGmail(
                    gmailClient: GmailClient(authManager: authManager),
                    parser: ReceiptParser(),
                    fetchWindowDays: 30
                )
            }
        }
    }
}

private extension RestingView {
    func formattedAmount(_ cents: Int) -> String {
        let symbol = AppConfig.Defaults.currentCurrencySymbol()
        return String(format: "\(symbol)%.2f", Double(cents) / 100.0)
    }
}

#Preview {
    RestingView(authManager: GoogleAuthManager())
        .environmentObject(NavigationRouter())
        .environmentObject(LedgerStore.shared)
}

//
//  RestingView.swift
//  ledger
//
//  Minimalist resting state - just the amount, swipe up to reveal app
//

import SwiftUI

struct RestingView: View {
    @EnvironmentObject var router: NavigationRouter
    @EnvironmentObject var store: LedgerStore

    @State private var appeared = false

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
        }
    }
}

#Preview {
    RestingView()
        .environmentObject(NavigationRouter())
        .environmentObject(LedgerStore.shared)
}

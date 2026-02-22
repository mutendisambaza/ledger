//
//  EmptyStateView.swift
//  ledger
//
//  Calm empty state — no drama, no gamification.
//

import SwiftUI

struct EmptyStateView: View {
    @State private var appeared = false

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.xs) {
            Image(systemName: "eye")
                .font(.system(size: 28, weight: .ultraLight))
                .foregroundColor(DesignSystem.Colors.secondaryText)

            Text("No spending detected")
                .font(DesignSystem.Typography.bodyMedium)
                .foregroundColor(DesignSystem.Colors.secondaryText)

            Text("Ledger is watching")
                .font(DesignSystem.Typography.caption)
                .foregroundColor(DesignSystem.Colors.secondaryText.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignSystem.Spacing.xl)
        .opacity(appeared ? 1 : 0)
        .onAppear {
            withAnimation(.easeOut(duration: 0.4).delay(0.25)) {
                appeared = true
            }
        }
    }
}

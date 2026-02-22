//
//  TransactionRow.swift
//  ledger
//
//  Staggered list row — slides from bottom 12pt, never from top.
//  Delay: 55ms per row. Wealthsimple standard.
//

import SwiftUI

struct TransactionRow: View {
    let transaction: Transaction
    let index: Int

    @State private var appeared = false

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            // Merchant + timestamp
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxxs) {
                Text(transaction.merchant)
                    .font(DesignSystem.Typography.bodyMedium)
                    .foregroundColor(DesignSystem.Colors.primaryText)
                    .lineLimit(1)

                Text(transaction.timestamp, style: .time)
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
            }

            Spacer(minLength: DesignSystem.Spacing.sm)

            // Amount — monospaced, right-aligned
            AmountText(cents: transaction.amountCents)
        }
        .padding(.vertical, DesignSystem.Spacing.xxs)
        // Entry animation: slide from 12pt below + fade in
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 12)
        .onAppear {
            withAnimation(.listRow(index)) {
                appeared = true
            }
        }
        .accessibilityLabel("\(transaction.merchant), \(formattedAmount), \(relativeTime)")
    }

    private var formattedAmount: String {
        String(format: "$%.2f", Double(transaction.amountCents) / 100.0)
    }

    private var relativeTime: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: transaction.timestamp, relativeTo: Date())
    }
}

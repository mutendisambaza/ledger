//
//  TransactionRow.swift
//  ledger
//
//  Created for Ledger Phase 3
//

import SwiftUI

struct TransactionRow: View {
    let transaction: Transaction
    let index: Int
    @State private var appeared = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.merchant)
                    .font(.body)
                    .foregroundColor(.white)
                Text(transaction.timestamp, style: .time)
                    .font(.caption)
                    .foregroundColor(Color(hex: "A1A1AA"))
            }
            Spacer()
            AmountText(cents: transaction.amountCents)
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
        .onAppear {
            withAnimation(.ledgerFast.delay(Double(index) * 0.05)) {
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

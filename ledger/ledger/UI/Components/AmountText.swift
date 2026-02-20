//
//  AmountText.swift
//  ledger
//
//  Created for Ledger Phase 3
//

import SwiftUI

struct AmountText: View {
    let cents: Int
    var style: Font = .body
    
    var body: some View {
        Text(formatAmount(cents))
            .font(style.monospacedDigit())
            .foregroundColor(.white)
    }
    
    private func formatAmount(_ cents: Int) -> String {
        let dollars = Double(cents) / 100.0
        return String(format: "\(AppConfig.Defaults.currencySymbol)%.2f", dollars)
    }
}


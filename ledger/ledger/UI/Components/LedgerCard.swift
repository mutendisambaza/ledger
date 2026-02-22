//
//  LedgerCard.swift
//  ledger
//
//  Created for Ledger Phase 3
//

import SwiftUI

struct LedgerCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(DesignSystem.Spacing.md)
            .background(DesignSystem.Colors.surface)
            .cornerRadius(DesignSystem.CornerRadius.lg)
    }
}


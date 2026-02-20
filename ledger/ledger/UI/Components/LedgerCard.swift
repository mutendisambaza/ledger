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
            .padding(16)
            .background(Color(hex: "171717"))
            .cornerRadius(16)
    }
}


//
//  HeroCard.swift
//  ledger
//
//  Created for Ledger Phase 3
//

import SwiftUI

struct HeroCard<Content: View>: View {
    let content: Content
    @State private var appeared = false
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(24)
            .glassCard()
            .shadow(color: Color(hex: "3B82F6").opacity(0.15), radius: 20, x: 0, y: 10)
            .scaleEffect(appeared ? 1 : 0.95)
            .opacity(appeared ? 1 : 0)
            .onAppear {
                withAnimation(.ledgerSpring) {
                    appeared = true
                }
            }
    }
}


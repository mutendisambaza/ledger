//
//  GlassBackground.swift
//  ledger
//
//  Created for Ledger Phase 3
//

import SwiftUI

struct GlassBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    Color(hex: "171717").opacity(0.7)
                    
                    // Blur layer
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)
                        .opacity(0.3)
                    
                    // Gradient border
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.2),
                                    Color.white.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
            )
            .cornerRadius(16)
    }
}

extension View {
    func glassCard() -> some View {
        modifier(GlassBackground())
    }
}


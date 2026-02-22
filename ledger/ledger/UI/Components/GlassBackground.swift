//
//  GlassBackground.swift
//  ledger
//
//  Machined aluminum card modifier — solid surface, whisper-thin border.
//  Less frosted window, more refined material.
//

import SwiftUI

struct GlassBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    // Solid surface — the refined base
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                        .fill(DesignSystem.Colors.surface)

                    // Whisper-thin border — top catches light, bottom recedes
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.09),
                                    Color.white.opacity(0.03)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: DesignSystem.Effects.borderWidth
                        )
                }
            )
    }
}

extension View {
    func glassCard() -> some View {
        modifier(GlassBackground())
    }
}

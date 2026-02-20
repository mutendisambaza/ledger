//
//  GlowEffect.swift
//  ledger
//
//  Glowing shadow effect for text and components
//

import SwiftUI

struct GlowEffectModifier: ViewModifier {
    let color: Color
    let radius: CGFloat
    let intensity: Double

    func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(0.6 * intensity), radius: radius, x: 0, y: 0)
            .shadow(color: color.opacity(0.4 * intensity), radius: radius * 1.5, x: 0, y: 0)
            .shadow(color: color.opacity(0.2 * intensity), radius: radius * 2, x: 0, y: 0)
    }
}

struct PulsingGlowModifier: ViewModifier {
    let color: Color
    let radius: CGFloat

    @State private var isGlowing = false

    func body(content: Content) -> some View {
        content
            .modifier(GlowEffectModifier(
                color: color,
                radius: radius,
                intensity: isGlowing ? 1.0 : 0.5
            ))
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 2)
                    .repeatForever(autoreverses: true)
                ) {
                    isGlowing = true
                }
            }
    }
}

extension View {
    /// Adds a static glow effect
    /// - Parameters:
    ///   - color: The color of the glow
    ///   - radius: The radius of the glow
    ///   - intensity: The intensity of the glow (0.0 - 1.0)
    func glow(
        color: Color = DesignSystem.Colors.glowingWhite,
        radius: CGFloat = DesignSystem.Effects.glowRadius,
        intensity: Double = 1.0
    ) -> some View {
        modifier(GlowEffectModifier(color: color, radius: radius, intensity: intensity))
    }

    /// Adds a pulsing glow effect
    /// - Parameters:
    ///   - color: The color of the glow
    ///   - radius: The radius of the glow
    func pulsingGlow(
        color: Color = DesignSystem.Colors.glowingWhite,
        radius: CGFloat = DesignSystem.Effects.glowRadius
    ) -> some View {
        modifier(PulsingGlowModifier(color: color, radius: radius))
    }
}

//
//  GlowEffect.swift
//  ledger
//
//  Ambient glow — restraint is the upgrade.
//  Rule: max one glow element per scroll viewport.
//  Opacity ceiling: 0.12–0.18 (ambient, not spotlight).
//  Never glow text — only glow container backgrounds.
//

import SwiftUI

struct GlowEffectModifier: ViewModifier {
    let color: Color
    let radius: CGFloat
    /// 0.0 – 1.0 multiplier on the restrained base opacities.
    let intensity: Double

    func body(content: Content) -> some View {
        content
            // Inner — warmest, tightest
            .shadow(color: color.opacity(0.18 * intensity), radius: radius, x: 0, y: 0)
            // Mid — spreads the warmth
            .shadow(color: color.opacity(0.10 * intensity), radius: radius * 1.6, x: 0, y: 0)
            // Outer — barely there, defines the halo
            .shadow(color: color.opacity(0.05 * intensity), radius: radius * 2.4, x: 0, y: 0)
    }
}

struct PulsingGlowModifier: ViewModifier {
    let color: Color
    let radius: CGFloat

    @State private var pulse = false

    func body(content: Content) -> some View {
        content
            .modifier(GlowEffectModifier(
                color: color,
                radius: radius,
                intensity: pulse ? 1.0 : 0.45
            ))
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 2.8)
                    .repeatForever(autoreverses: true)
                ) {
                    pulse = true
                }
            }
    }
}

extension View {
    /// Adds a restrained ambient glow to a container element.
    /// Do NOT use on text — only on RoundedRectangle or other shapes.
    func glow(
        color: Color = DesignSystem.Colors.sageGreen,
        radius: CGFloat = DesignSystem.Effects.glowRadius,
        intensity: Double = 1.0
    ) -> some View {
        modifier(GlowEffectModifier(color: color, radius: radius, intensity: intensity))
    }

    /// Adds a slow-breathing ambient glow to a container element.
    func pulsingGlow(
        color: Color = DesignSystem.Colors.sageGreen,
        radius: CGFloat = DesignSystem.Effects.glowRadius
    ) -> some View {
        modifier(PulsingGlowModifier(color: color, radius: radius))
    }
}

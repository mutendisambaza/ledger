//
//  GlowingText.swift
//  ledger
//
//  Text with glow effect for amounts and headers
//

import SwiftUI

struct GlowingText: View {
    let text: String
    var font: Font = DesignSystem.Typography.heroAmount
    var color: Color = DesignSystem.Colors.glowingWhite
    var glowColor: Color? = nil
    var isPulsing: Bool = false

    var body: some View {
        Text(text)
            .font(font)
            .foregroundColor(color)
            .modifier(
                isPulsing
                    ? AnyViewModifier(
                        PulsingGlowModifier(
                            color: glowColor ?? color,
                            radius: DesignSystem.Effects.glowRadiusLarge
                        )
                    )
                    : AnyViewModifier(
                        GlowEffectModifier(
                            color: glowColor ?? color,
                            radius: DesignSystem.Effects.glowRadiusLarge,
                            intensity: 0.8
                        )
                    )
            )
    }
}

// Helper to erase ViewModifier type
struct AnyViewModifier: ViewModifier {
    private let _body: (Content) -> AnyView

    init<M: ViewModifier>(_ modifier: M) {
        _body = { content in
            AnyView(content.modifier(modifier))
        }
    }

    func body(content: Content) -> some View {
        _body(content)
    }
}

// MARK: - Convenience Views

struct AmountDisplay: View {
    let amountCents: Int
    var currency: String = "$"
    var size: AmountSize = .large
    var glowColor: Color = DesignSystem.Colors.sageGreen
    var isPulsing: Bool = false

    enum AmountSize {
        case small, medium, large, hero

        var font: Font {
            switch self {
            case .small: return DesignSystem.Typography.amountSmall
            case .medium: return DesignSystem.Typography.amountMedium
            case .large: return DesignSystem.Typography.amountLarge
            case .hero: return DesignSystem.Typography.heroAmount
            }
        }
    }

    var formattedAmount: String {
        let dollars = Double(amountCents) / 100.0
        return String(format: "%@%.2f", currency, dollars)
    }

    var body: some View {
        GlowingText(
            text: formattedAmount,
            font: size.font,
            color: .white,
            glowColor: glowColor,
            isPulsing: isPulsing
        )
    }
}

struct PlaceholderAmount: View {
    var currency: String = "$"
    var size: AmountDisplay.AmountSize = .large

    var body: some View {
        GlowingText(
            text: "\(currency)--.--",
            font: size.font,
            color: DesignSystem.Colors.glow(0.4),
            glowColor: DesignSystem.Colors.glow(0.3),
            isPulsing: true
        )
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 48) {
        AmountDisplay(amountCents: 2000, size: .hero)

        AmountDisplay(amountCents: 15000, size: .large, glowColor: DesignSystem.Colors.chromeSilver)

        AmountDisplay(amountCents: 500, size: .medium)

        PlaceholderAmount(size: .large)

        GlowingText(
            text: "Ledger",
            font: DesignSystem.Typography.splashText,
            isPulsing: true
        )
    }
    .padding()
    .background(DesignSystem.Colors.black)
}

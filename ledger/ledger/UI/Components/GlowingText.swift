//
//  GlowingText.swift
//  ledger
//
//  Currency displays — monospaced always, glow on the hero amount only.
//  Rule: never glow text directly. The glow modifier here applies to the
//  text container as an ambient halo, not a text-shadow decoration.
//

import SwiftUI

struct GlowingText: View {
    let text: String
    var font: Font = DesignSystem.Typography.heroAmount
    var color: Color = DesignSystem.Colors.primaryText
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
                            color: glowColor ?? DesignSystem.Colors.sageGreen,
                            radius: DesignSystem.Effects.glowRadiusLarge
                        )
                    )
                    : AnyViewModifier(
                        GlowEffectModifier(
                            color: glowColor ?? DesignSystem.Colors.sageGreen,
                            radius: DesignSystem.Effects.glowRadiusLarge,
                            intensity: 0.85
                        )
                    )
            )
    }
}

// Helper to erase ViewModifier type
struct AnyViewModifier: ViewModifier {
    private let _body: (Content) -> AnyView

    init<M: ViewModifier>(_ modifier: M) {
        _body = { content in AnyView(content.modifier(modifier)) }
    }

    func body(content: Content) -> some View {
        _body(content)
    }
}

// MARK: - AmountDisplay

struct AmountDisplay: View {
    let amountCents: Int
    var currency: String = AppConfig.Defaults.currentCurrencySymbol()
    var size: AmountSize = .large
    var glowColor: Color = DesignSystem.Colors.sageGreen
    var isPulsing: Bool = false

    enum AmountSize {
        case small, medium, large, hero

        var font: Font {
            switch self {
            case .small:  return DesignSystem.Typography.amountSmall
            case .medium: return DesignSystem.Typography.amountMedium
            case .large:  return DesignSystem.Typography.amountLarge
            case .hero:   return DesignSystem.Typography.heroAmount
            }
        }
    }

    var formattedAmount: String {
        String(format: "%@%.2f", currency, Double(amountCents) / 100.0)
    }

    var body: some View {
        GlowingText(
            text: formattedAmount,
            font: size.font,
            color: DesignSystem.Colors.primaryText,
            glowColor: glowColor,
            isPulsing: isPulsing
        )
        .accessibilityLabel("Total spent: \(formattedAmount)")
        .accessibilityAddTraits(.updatesFrequently)
    }
}

// MARK: - PlaceholderAmount

struct PlaceholderAmount: View {
    var currency: String = AppConfig.Defaults.currentCurrencySymbol()
    var size: AmountDisplay.AmountSize = .large

    var body: some View {
        GlowingText(
            text: "\(currency)--.--",
            font: size.font,
            color: DesignSystem.Colors.secondaryText,
            glowColor: DesignSystem.Colors.secondaryText,
            isPulsing: true
        )
    }
}

struct WaveLoadingAmount: View {
    var currency: String = AppConfig.Defaults.currentCurrencySymbol()
    var size: AmountDisplay.AmountSize = .large

    @State private var phase: Double = 0

    private let characters = Array("--.--")

    var body: some View {
        HStack(spacing: 1) {
            Text(currency)
                .font(size.font)
                .foregroundColor(DesignSystem.Colors.glow(0.5))

            ForEach(characters.indices, id: \.self) { index in
                Text(String(characters[index]))
                    .font(size.font)
                    .foregroundColor(DesignSystem.Colors.glow(0.7))
                    .offset(y: waveOffset(for: index))
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 1.1).repeatForever(autoreverses: false)) {
                phase = .pi * 2
            }
        }
    }

    private func waveOffset(for index: Int) -> CGFloat {
        let wave = sin(phase + (Double(index) * 0.55))
        return CGFloat(-wave * 5.0)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: DesignSystem.Spacing.xl) {
        AmountDisplay(amountCents: 23456, size: .hero)
        AmountDisplay(amountCents: 15000, size: .large)
        AmountDisplay(amountCents: 500, size: .medium)
        PlaceholderAmount(size: .large)
    }
    .padding(DesignSystem.Spacing.md)
    .background(DesignSystem.Colors.black)
}

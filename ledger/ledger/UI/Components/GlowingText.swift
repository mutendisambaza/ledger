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
    var currency: String = "$"
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
    var currency: String = "$"
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

// MARK: - SlotAmountDisplay

/// Slot-machine digit roller. Each digit spins through 0–9 in alternating
/// directions, stopping at a random time ≤ 1.2 s, then snaps to the correct
/// value. Non-digit characters ($ and .) render statically with no animation.
/// Re-spins automatically whenever `amountCents` changes.
struct SlotAmountDisplay: View {
    let amountCents: Int
    var currency: String = "$"
    var size: AmountDisplay.AmountSize = .hero
    var glowColor: Color = DesignSystem.Colors.sageGreen

    private var formattedAmount: String {
        String(format: "%@%.2f", currency, Double(amountCents) / 100.0)
    }

    private func lineHeight(for size: AmountDisplay.AmountSize) -> CGFloat {
        switch size {
        case .hero:   return 78
        case .large:  return 58
        case .medium: return 40
        case .small:  return 28
        }
    }

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            ForEach(Array(formattedAmount.enumerated()), id: \.offset) { index, char in
                SlotDigit(
                    character: char,
                    columnIndex: index,
                    font: size.font,
                    lineHeight: lineHeight(for: size)
                )
            }
        }
        .modifier(GlowEffectModifier(
            color: glowColor,
            radius: DesignSystem.Effects.glowRadiusLarge,
            intensity: 0.85
        ))
        .accessibilityLabel("Total spent: \(formattedAmount)")
        .accessibilityAddTraits(.updatesFrequently)
    }
}

// MARK: - SlotDigit

private struct SlotDigit: View {
    let character: Character
    let columnIndex: Int
    let font: Font
    let lineHeight: CGFloat

    @State private var displayed: Character = "0"
    @State private var spinTask: Task<Void, Never>?

    private var isDigit: Bool { character.isNumber }
    private var target: Int { Int(String(character)) ?? 0 }
    // Even columns roll downward (digits increase), odd columns roll upward (digits decrease)
    private var rollsDown: Bool { columnIndex % 2 == 0 }

    var body: some View {
        ZStack {
            if isDigit {
                Text(String(displayed))
                    .font(font)
                    .monospacedDigit()
                    .foregroundColor(DesignSystem.Colors.primaryText)
                    .id(displayed)
                    .transition(.asymmetric(
                        insertion: .move(edge: rollsDown ? .bottom : .top).combined(with: .opacity),
                        removal:   .move(edge: rollsDown ? .top   : .bottom).combined(with: .opacity)
                    ))
            } else {
                Text(String(character))
                    .font(font)
                    .monospacedDigit()
                    .foregroundColor(DesignSystem.Colors.primaryText)
            }
        }
        .frame(height: lineHeight)
        .clipped()
        .onAppear {
            // Start from a random digit so the reel looks like it's already in motion
            displayed = Character("\(Int.random(in: 0...9))")
            beginSpin()
        }
        .onChange(of: character) { _, _ in
            beginSpin()
        }
        .onDisappear {
            spinTask?.cancel()
        }
    }

    private func beginSpin() {
        spinTask?.cancel()
        spinTask = Task { @MainActor in
            guard isDigit else {
                displayed = character
                return
            }
            let ticks = Int.random(in: 7...14)
            let totalTime = Double.random(in: 0.55...1.2)
            let tickInterval = totalTime / Double(ticks)

            for _ in 0..<ticks {
                guard !Task.isCancelled else { return }
                try? await Task.sleep(for: .seconds(tickInterval))
                guard !Task.isCancelled else { return }
                withAnimation(.linear(duration: tickInterval * 0.65)) {
                    let cur = Int(String(displayed)) ?? 0
                    let next = rollsDown ? (cur + 1) % 10 : (cur + 9) % 10
                    displayed = Character("\(next)")
                }
            }
            // Final precise snap
            guard !Task.isCancelled else { return }
            withAnimation(.spring(duration: 0.18, bounce: 0.0)) {
                displayed = Character("\(target)")
            }
        }
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

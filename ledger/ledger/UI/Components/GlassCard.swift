//
//  GlassCard.swift
//  ledger
//
//  Premium surface card — machined aluminium, not frosted glass.
//  Design principle: the border defines the card, not the blur.
//  Cards breathe — padding is never tight, borders are whisper-thin.
//

import SwiftUI

// MARK: - GlassCard

struct GlassCard<Content: View>: View {
    let content: Content
    var padding: CGFloat
    var variant: Variant
    var showBorder: Bool

    enum Variant {
        case `default`
        case selected   // Accent-tinted, for active/chosen state
        case danger     // Danger-tinted, for errors / over-budget

        var background: Color {
            switch self {
            case .default: return DesignSystem.Colors.surface
            case .selected: return DesignSystem.Colors.sage(0.08)
            case .danger: return DesignSystem.Colors.dangerColor.opacity(0.07)
            }
        }

        var borderTopColor: Color {
            switch self {
            case .default: return Color.white.opacity(0.09)
            case .selected: return DesignSystem.Colors.sageGreen.opacity(0.22)
            case .danger: return DesignSystem.Colors.dangerColor.opacity(0.22)
            }
        }

        var borderBottomColor: Color {
            switch self {
            case .default: return Color.white.opacity(0.03)
            case .selected: return DesignSystem.Colors.sageGreen.opacity(0.08)
            case .danger: return DesignSystem.Colors.dangerColor.opacity(0.08)
            }
        }
    }

    init(
        padding: CGFloat = DesignSystem.Spacing.md,
        variant: Variant = .default,
        showBorder: Bool = true,
        @ViewBuilder content: () -> Content
    ) {
        self.padding = padding
        self.variant = variant
        self.showBorder = showBorder
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .background(cardBackground)
    }

    private var cardBackground: some View {
        ZStack {
            // Solid surface — the "machined" base, no blurry frosting
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                .fill(variant.background)

            // Whisper-thin border — catches light on top, recedes on bottom
            if showBorder {
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                variant.borderTopColor,
                                variant.borderBottomColor
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: DesignSystem.Effects.borderWidth
                    )
            }
        }
    }
}

// MARK: - SageGlassCard
// Accent-tinted variant for insight/success states.

struct SageGlassCard<Content: View>: View {
    let content: Content
    var padding: CGFloat = DesignSystem.Spacing.md

    init(
        padding: CGFloat = DesignSystem.Spacing.md,
        @ViewBuilder content: () -> Content
    ) {
        self.padding = padding
        self.content = content()
    }

    var body: some View {
        GlassCard(padding: padding, variant: .selected) {
            content
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: DesignSystem.Spacing.md) {
        GlassCard {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                Text("Default Card")
                    .font(DesignSystem.Typography.cardHeader)
                    .foregroundColor(DesignSystem.Colors.primaryText)
                Text("Whisper-thin border, solid surface")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.secondaryText)
            }
        }

        GlassCard(variant: .selected) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                Text("Selected Card")
                    .font(DesignSystem.Typography.cardHeader)
                    .foregroundColor(DesignSystem.Colors.primaryText)
                Text("Accent-tinted for active states")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.sageGreen)
            }
        }

        GlassCard(variant: .danger) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xxs) {
                Text("Danger Card")
                    .font(DesignSystem.Typography.cardHeader)
                    .foregroundColor(DesignSystem.Colors.primaryText)
                Text("For over-budget or error states")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.dangerColor)
            }
        }
    }
    .padding(DesignSystem.Spacing.md)
    .background(DesignSystem.Colors.black)
}

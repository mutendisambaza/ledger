//
//  GlassCard.swift
//  ledger
//
//  Enhanced glassmorphic card with chrome border and glow
//

import SwiftUI

struct GlassCard<Content: View>: View {
    let content: Content
    var padding: CGFloat = DesignSystem.Spacing.md
    var glowIntensity: Double = 0.3
    var showChrome: Bool = true

    init(
        padding: CGFloat = DesignSystem.Spacing.md,
        glowIntensity: Double = 0.3,
        showChrome: Bool = true,
        @ViewBuilder content: () -> Content
    ) {
        self.padding = padding
        self.glowIntensity = glowIntensity
        self.showChrome = showChrome
        self.content = content()
    }

    var body: some View {
        content
            .padding(padding)
            .background(
                ZStack {
                    // Dark glass background
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                        .fill(
                            LinearGradient(
                                colors: [
                                    DesignSystem.Colors.darkGrey.opacity(0.4),
                                    DesignSystem.Colors.darkGrey.opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .background(.ultraThinMaterial)

                    // Chrome border gradient
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    DesignSystem.Colors.chrome(0.6),
                                    DesignSystem.Colors.chrome(0.3),
                                    DesignSystem.Colors.chrome(0.1),
                                    DesignSystem.Colors.chrome(0.3),
                                    DesignSystem.Colors.chrome(0.6)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                        .opacity(showChrome ? 1 : 0)
                }
            )
            .glow(
                color: DesignSystem.Colors.glowingWhite,
                radius: DesignSystem.Effects.glowRadius,
                intensity: glowIntensity
            )
    }
}

// MARK: - Sage Variant

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
        content
            .padding(padding)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                        .fill(
                            LinearGradient(
                                colors: [
                                    DesignSystem.Colors.sage(0.2),
                                    DesignSystem.Colors.sage(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .background(.ultraThinMaterial)

                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                        .strokeBorder(
                            DesignSystem.Colors.sageGreen.opacity(0.5),
                            lineWidth: 1.5
                        )
                }
            )
            .glow(color: DesignSystem.Colors.sageGreen, radius: 16, intensity: 0.4)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 32) {
        GlassCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Chrome Glass Card")
                    .font(DesignSystem.Typography.cardHeader)
                    .foregroundColor(.white)

                Text("With subtle glow and chrome border")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.glow(0.7))
            }
        }

        SageGlassCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Sage Glass Card")
                    .font(DesignSystem.Typography.cardHeader)
                    .foregroundColor(.white)

                Text("With sage green accent glow")
                    .font(DesignSystem.Typography.caption)
                    .foregroundColor(DesignSystem.Colors.sage(0.9))
            }
        }
    }
    .padding()
    .background(DesignSystem.Colors.black)
}

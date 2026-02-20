//
//  GlassButton.swift
//  ledger
//
//  Glassmorphic button with pressed state and glow effect
//

import SwiftUI

struct GlassButton: View {
    let title: String
    let icon: String?
    let action: () -> Void

    var style: ButtonStyle = .primary
    var isCompact: Bool = false

    @State private var isPressed = false

    enum ButtonStyle {
        case primary
        case secondary
        case minimal

        var backgroundColor: Color {
            switch self {
            case .primary:
                return DesignSystem.Colors.sage(0.15)
            case .secondary:
                return DesignSystem.Colors.chrome(0.1)
            case .minimal:
                return Color.clear
            }
        }

        var borderColor: Color {
            switch self {
            case .primary:
                return DesignSystem.Colors.sageGreen
            case .secondary:
                return DesignSystem.Colors.chromeSilver
            case .minimal:
                return DesignSystem.Colors.glow(0.2)
            }
        }

        var glowColor: Color {
            switch self {
            case .primary:
                return DesignSystem.Colors.sageGreen
            case .secondary, .minimal:
                return DesignSystem.Colors.glowingWhite
            }
        }
    }

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = false
                }
                action()
            }
        }) {
            HStack(spacing: DesignSystem.Spacing.xs) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(isCompact ? .body : .title3)
                }

                Text(title)
                    .font(isCompact ? DesignSystem.Typography.caption : DesignSystem.Typography.bodyMedium)
                    .fontWeight(.semibold)
            }
            .foregroundColor(DesignSystem.Colors.glowingWhite)
            .padding(.horizontal, isCompact ? DesignSystem.Spacing.sm : DesignSystem.Spacing.md)
            .padding(.vertical, isCompact ? DesignSystem.Spacing.xs : DesignSystem.Spacing.sm)
            .background(
                ZStack {
                    // Glass background
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                        .fill(style.backgroundColor)
                        .background(.ultraThinMaterial)

                    // Border
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    style.borderColor.opacity(0.6),
                                    style.borderColor.opacity(0.3)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                    .fill(Color.white.opacity(isPressed ? 0.2 : 0))
            )
            .glow(color: style.glowColor, radius: isPressed ? 20 : 8, intensity: isPressed ? 0.8 : 0.4)
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .chromeEffect(animated: false)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Convenience Initializers

extension GlassButton {
    init(
        _ title: String,
        icon: String? = nil,
        style: ButtonStyle = .primary,
        isCompact: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.style = style
        self.isCompact = isCompact
        self.action = action
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 24) {
        GlassButton("Primary Button", icon: "star.fill", style: .primary) {}
        GlassButton("Secondary Button", icon: "gear", style: .secondary) {}
        GlassButton("Minimal Button", style: .minimal) {}
        GlassButton("Compact", icon: "plus", isCompact: true) {}
    }
    .padding()
    .background(DesignSystem.Colors.black)
}

//
//  GlassButton.swift
//  ledger
//
//  Surface button with physical press feedback and inline loading state.
//  Loading state: spinner + label, no press animation, no bounce.
//

import SwiftUI

struct GlassButton: View {
    let title: String
    let icon: String?
    let action: () -> Void

    var style: ButtonStyle = .primary
    var isCompact: Bool = false
    /// When true, shows a spinner instead of the icon and disables interaction.
    var isLoading: Bool = false
    /// Text shown while isLoading is true.
    var loadingTitle: String?

    @Environment(\.isEnabled) private var isEnabled

    enum ButtonStyle {
        case primary
        case secondary
        case minimal

        func backgroundColor(isEnabled: Bool) -> Color {
            switch self {
            case .primary:
                return isEnabled ? DesignSystem.Colors.accent : .clear
            case .secondary:
                return isEnabled ? DesignSystem.Colors.chrome(0.1) : .clear
            case .minimal:
                return Color.clear
            }
        }

        func borderColor(isEnabled: Bool) -> Color {
            switch self {
            case .primary:
                return DesignSystem.Colors.accent.opacity(isEnabled ? 1 : 0.9)
            case .secondary:
                return DesignSystem.Colors.chromeSilver.opacity(isEnabled ? 1 : 0.9)
            case .minimal:
                return DesignSystem.Colors.glow(0.2)
            }
        }

        func glowColor(isEnabled: Bool) -> Color {
            switch self {
            case .primary:
                return isEnabled ? DesignSystem.Colors.accent : .clear
            case .secondary, .minimal:
                return DesignSystem.Colors.glowingWhite
            }
        }

        func foregroundColor(isEnabled: Bool) -> Color {
            switch self {
            case .primary:
                return isEnabled ? DesignSystem.Colors.black : DesignSystem.Colors.accent
            case .secondary:
                return isEnabled ? DesignSystem.Colors.glowingWhite : DesignSystem.Colors.chromeSilver
            case .minimal:
                return DesignSystem.Colors.glowingWhite
            }
        }
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignSystem.Spacing.xs) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: prefs.accent))
                        .scaleEffect(isCompact ? 0.7 : 0.85)
                } else if let icon = icon {
                    Image(systemName: icon)
                        .font(isCompact ? .footnote : .body)
                        .fontWeight(.medium)
                }

                Text(isLoading ? (loadingTitle ?? title) : title)
                    .font(isCompact ? DesignSystem.Typography.captionMedium : DesignSystem.Typography.bodyMedium)
                    .fontWeight(.medium)
            }
            .foregroundColor(style.foregroundColor(isEnabled: isEnabled))
            .padding(.horizontal, isCompact ? DesignSystem.Spacing.sm : DesignSystem.Spacing.md)
            .padding(.vertical, isCompact ? DesignSystem.Spacing.xs : DesignSystem.Spacing.sm)
            .background(
                ZStack {
                    // Glass background
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                        .fill(style.backgroundColor(isEnabled: isEnabled))
                        .background(.ultraThinMaterial)

                    // Border
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    style.borderColor(isEnabled: isEnabled).opacity(0.9),
                                    style.borderColor(isEnabled: isEnabled).opacity(0.65)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                }
            )
            .glow(color: style.glowColor(isEnabled: isEnabled), radius: 10, intensity: 0.28)
            .chromeEffect(animated: false)
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.easeInOut(duration: 0.22), value: isEnabled)
    }
}

extension GlassButton {
    init(
        _ title: String,
        icon: String? = nil,
        style: ButtonStyle = .primary,
        isCompact: Bool = false,
        isLoading: Bool = false,
        loadingTitle: String? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.style = style
        self.isCompact = isCompact
        self.isLoading = isLoading
        self.loadingTitle = loadingTitle
        self.action = action
    }
}

#Preview {
    VStack(spacing: DesignSystem.Spacing.md) {
        GlassButton("Rebalance Ledger", icon: "arrow.clockwise") {}
            .environmentObject(UserPreferences())
        GlassButton("Rebalance Ledger", icon: "arrow.clockwise",
                    isLoading: true, loadingTitle: "Rebalancing…") {}
            .environmentObject(UserPreferences())
        GlassButton("Secondary", style: .secondary) {}
            .environmentObject(UserPreferences())
    }
    .padding(DesignSystem.Spacing.md)
    .background(DesignSystem.Colors.black)
}

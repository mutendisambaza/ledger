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

    @State private var isPressed = false
    @EnvironmentObject var prefs: UserPreferences

    enum ButtonStyle {
        case primary
        case secondary
        case minimal

        var backgroundColor: Color {
            switch self {
            case .primary:             return DesignSystem.Colors.surface
            case .secondary, .minimal: return DesignSystem.Colors.surface
            }
        }
    }

    var body: some View {
        Button(action: {
            guard !isLoading else { return }
            withAnimation(.stateToggle) { isPressed = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.10) {
                withAnimation(.stateToggle) { isPressed = false }
                action()
            }
        }) {
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
            .foregroundColor(style == .primary ? prefs.accent : DesignSystem.Colors.secondaryText)
            .padding(.horizontal, isCompact ? DesignSystem.Spacing.sm : DesignSystem.Spacing.md)
            .padding(.vertical, isCompact ? DesignSystem.Spacing.xxs : DesignSystem.Spacing.sm)
            .background(buttonBackground)
            .scaleEffect((!isLoading && isPressed) ? 0.97 : 1.0)
            .shadow(
                color: prefs.accent.opacity((!isLoading && isPressed) ? 0.20 : 0),
                radius: 12
            )
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isLoading)
        .animation(.stateToggle, value: isPressed)
        .animation(.stateToggle, value: isLoading)
    }

    private var buttonBackground: some View {
        let borderColor: Color = style == .primary
            ? prefs.accent.opacity(0.28)
            : DesignSystem.Colors.borderDefault

        return ZStack {
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                .fill(style.backgroundColor)
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                .strokeBorder(
                    LinearGradient(
                        colors: [borderColor, borderColor.opacity(0.5)],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: DesignSystem.Effects.borderWidth
                )
        }
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

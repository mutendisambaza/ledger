//
//  TimePeriodToggle.swift
//  ledger
//
//  Segmented period selector — selected indicator uses the current accent color.
//

import SwiftUI

struct TimePeriodToggle: View {
    @ObservedObject var periodManager: TimePeriodManager
    @EnvironmentObject var prefs: UserPreferences

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.xxxs) {
            ForEach(TimePeriod.allCases) { period in
                PeriodButton(
                    period: period,
                    isSelected: periodManager.selectedPeriod == period,
                    accent: prefs.accent,
                    action: {
                        withAnimation(.stateToggle) {
                            periodManager.selectedPeriod = period
                        }
                    }
                )
            }
        }
        .padding(3)
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                    .fill(DesignSystem.Colors.surface)
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                    .strokeBorder(DesignSystem.Colors.borderDefault, lineWidth: DesignSystem.Effects.borderWidth)
            }
        )
    }
}

private struct PeriodButton: View {
    let period: TimePeriod
    let isSelected: Bool
    let accent: Color
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            Text(period.rawValue)
                .font(DesignSystem.Typography.captionMedium)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(
                    isSelected
                        ? DesignSystem.Colors.black
                        : DesignSystem.Colors.secondaryText
                )
                .padding(.horizontal, DesignSystem.Spacing.xs)
                .padding(.vertical, 7)
                .background(
                    Group {
                        if isSelected {
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                                .fill(accent)
                        } else {
                            Color.clear
                        }
                    }
                )
                .scaleEffect(isPressed ? 0.96 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.stateToggle, value: isSelected)
        .animation(.spring(duration: 0.14, bounce: 0.0), value: isPressed)
        .accessibilityLabel("\(period.rawValue) period")
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in if !isPressed { isPressed = true } }
                .onEnded { _ in isPressed = false }
        )
    }
}

extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition { transform(self) } else { self }
    }
}

#Preview {
    VStack(spacing: DesignSystem.Spacing.xl) {
        TimePeriodToggle(periodManager: TimePeriodManager())
        TimePeriodToggle(periodManager: {
            let m = TimePeriodManager(); m.selectedPeriod = .week; return m
        }())
    }
    .padding(DesignSystem.Spacing.md)
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(DesignSystem.Colors.black)
    .environmentObject(UserPreferences())
}

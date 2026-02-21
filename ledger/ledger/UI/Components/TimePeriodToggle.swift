//
//  TimePeriodToggle.swift
//  ledger
//
//  Glassmorphic segmented control for time period selection
//

import SwiftUI

struct TimePeriodToggle: View {
    @ObservedObject var periodManager: TimePeriodManager

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.xxs) {
            ForEach(TimePeriod.allCases) { period in
                PeriodButton(
                    period: period,
                    isSelected: periodManager.selectedPeriod == period,
                    action: {
                        withAnimation(Animation.glassMorphSpring) {
                            periodManager.selectedPeriod = period
                        }
                    }
                )
            }
        }
        .padding(DesignSystem.Spacing.xxxs)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                .fill(DesignSystem.Colors.glow(0.05))
                .background(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                        .fill(.ultraThinMaterial)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                        .stroke(DesignSystem.Colors.chrome(0.3), lineWidth: 1)
                )
        )
    }
}

private struct PeriodButton: View {
    let period: TimePeriod
    let isSelected: Bool
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            Text(period.rawValue)
                .font(DesignSystem.Typography.caption)
                .fontWeight(isSelected ? .bold : .regular)
                .foregroundColor(
                    isSelected ? DesignSystem.Colors.black : DesignSystem.Colors.glow(0.7)
                )
                .padding(.horizontal, DesignSystem.Spacing.xs)
                .padding(.vertical, DesignSystem.Spacing.xxs)
                .background(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                        .fill(
                            isSelected
                                ? DesignSystem.Colors.sageGreen
                                : Color.clear
                        )
                        .if(isSelected) { view in
                            view.glow(
                                color: DesignSystem.Colors.sageGreen,
                                radius: DesignSystem.Effects.glowRadius,
                                intensity: 0.6
                            )
                        }
                )
                .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("\(period.rawValue) period")
        .accessibilityValue(isSelected ? "Selected" : "Not selected")
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isPressed {
                        withAnimation(.easeIn(duration: 0.1)) {
                            isPressed = true
                        }
                    }
                }
                .onEnded { _ in
                    withAnimation(.easeOut(duration: 0.1)) {
                        isPressed = false
                    }
                }
        )
    }
}

// Helper extension for conditional modifiers
extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

#Preview {
    VStack(spacing: 40) {
        TimePeriodToggle(periodManager: TimePeriodManager())
            .padding()

        // Preview with different states
        VStack {
            Text("Preview States")
                .font(DesignSystem.Typography.cardHeader)
                .foregroundColor(.white)

            TimePeriodToggle(periodManager: {
                let manager = TimePeriodManager()
                manager.selectedPeriod = .week
                return manager
            }())
        }
        .padding()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(DesignSystem.Colors.black)
}

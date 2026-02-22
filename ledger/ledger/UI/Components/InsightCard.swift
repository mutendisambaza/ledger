//
//  InsightCard.swift
//  ledger
//
//  Calm, informational — "Ledger noticed…" tone, never urgent.
//  Entry: slides from bottom 10pt (content pattern, not notification).
//

import SwiftUI

struct InsightCard: View {
    let insight: Insight
    var onDismiss: (() -> Void)? = nil

    @State private var appeared = false

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            // Icon pill — blue accent, restrained
            Circle()
                .fill(DesignSystem.Colors.blue.opacity(0.12))
                .frame(width: 30, height: 30)
                .overlay(
                    Image(systemName: iconName)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(DesignSystem.Colors.blue)
                )

            Text(insight.message)
                .font(DesignSystem.Typography.caption)
                .foregroundColor(DesignSystem.Colors.secondaryText)
                .lineLimit(2)
                .multilineTextAlignment(.leading)

            Spacer(minLength: 0)

            if let onDismiss = onDismiss {
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(DesignSystem.Colors.secondaryText)
                }
            }
        }
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.xs)
        .glassCard()
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
        .onAppear {
            withAnimation(.alertAppear.delay(0.15)) {
                appeared = true
            }
        }
    }

    private var iconName: String {
        switch insight.type {
        case .accumulation:  return "arrow.up.right"
        case .velocity:      return "clock"
        case .unusual:       return "exclamationmark.circle"
        case .aboveAverage:  return "chart.line.uptrend.xyaxis"
        }
    }
}

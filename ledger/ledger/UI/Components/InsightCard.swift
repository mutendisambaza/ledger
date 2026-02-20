//
//  InsightCard.swift
//  ledger
//
//  Created for Ledger Phase 3
//

import SwiftUI

struct InsightCard: View {
    let insight: Insight
    var onDismiss: (() -> Void)? = nil
    @State private var appeared = false
    
    var body: some View {
        HStack(spacing: 12) {
            // Subtle icon
            Circle()
                .fill(Color(hex: "3B82F6").opacity(0.2))
                .frame(width: 32, height: 32)
                .overlay(
                    Image(systemName: iconName)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(hex: "3B82F6"))
                )
            
            Text(insight.message)
                .font(.subheadline)
                .foregroundColor(.white)
            
            Spacer()
            
            if let onDismiss = onDismiss {
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(hex: "A1A1AA"))
                }
            }
        }
        .padding(16)
        .glassCard()
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : -10)
        .onAppear {
            withAnimation(.ledgerSpring.delay(0.2)) {
                appeared = true
            }
        }
    }
    
    private var iconName: String {
        switch insight.type {
        case .accumulation: return "arrow.up.right"
        case .velocity: return "clock"
        case .unusual: return "exclamationmark.circle"
        case .aboveAverage: return "chart.line.uptrend.xyaxis"
        }
    }
}


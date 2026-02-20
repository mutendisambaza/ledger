//
//  SyncButton.swift
//  ledger
//
//  Created for Ledger Phase 3
//

import SwiftUI

struct SyncButton: View {
    let isLoading: Bool
    let lastSync: Date?
    let action: () -> Void
    @State private var isPressed = false
    @State private var rotation: Double = 0
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: "arrow.clockwise")
                    .rotationEffect(.degrees(rotation))
                Text(isLoading ? "Syncing..." : "Sync from Gmail")
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                ZStack {
                    Color(hex: "3B82F6")
                    
                    // Subtle gradient overlay
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.1),
                            Color.clear
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
            )
            .foregroundColor(.white)
            .cornerRadius(12)
            .scaleEffect(isPressed ? 0.97 : 1)
        }
        .disabled(isLoading)
        .buttonStyle(PlainButtonStyle())
        .pressAction(onPress: { isPressed = true }, onRelease: { isPressed = false })
        .onChange(of: isLoading) { _, loading in
            if loading {
                withAnimation(.linear(duration: 1).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
            } else {
                withAnimation(.ledgerFast) {
                    rotation = 0
                }
            }
        }
    }
}

// Press gesture helper
struct PressAction: ViewModifier {
    var onPress: () -> Void
    var onRelease: () -> Void
    
    func body(content: Content) -> some View {
        content
            .simultaneousGesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { _ in onPress() }
                    .onEnded { _ in onRelease() }
            )
    }
}

extension View {
    func pressAction(onPress: @escaping () -> Void, onRelease: @escaping () -> Void) -> some View {
        modifier(PressAction(onPress: onPress, onRelease: onRelease))
    }
}


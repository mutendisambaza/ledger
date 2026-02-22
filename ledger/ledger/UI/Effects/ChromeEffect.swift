//
//  ChromeEffect.swift
//  ledger
//
//  Muted shimmer — barely perceptible, not theatrical.
//  Opacity ceiling: 0.14 max, blend mode overlay for realism.
//

import SwiftUI

struct ChromeEffectModifier: ViewModifier {
    @State private var shimmerOffset: CGFloat = -1
    @State private var viewWidth: CGFloat = 0
    let isAnimated: Bool

    func body(content: Content) -> some View {
        content
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .onAppear { viewWidth = geometry.size.width }
                }
            )
            .overlay(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0),
                        Color.white.opacity(0.07),
                        Color.white.opacity(0.14),
                        Color.white.opacity(0.07),
                        Color.white.opacity(0)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .offset(x: shimmerOffset * (viewWidth > 0 ? viewWidth : 400))
                .mask(content)
                .blendMode(.overlay)
                .opacity(isAnimated ? 1 : 0.3)
                .onAppear {
                    guard isAnimated else { return }
                    withAnimation(
                        .linear(duration: 2.5)
                        .repeatForever(autoreverses: false)
                    ) {
                        shimmerOffset = 1
                    }
                }
            )
    }
}

extension View {
    func chromeEffect(animated: Bool = true) -> some View {
        modifier(ChromeEffectModifier(isAnimated: animated))
    }
}

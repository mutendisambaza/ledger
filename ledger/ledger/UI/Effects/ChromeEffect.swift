//
//  ChromeEffect.swift
//  ledger
//
//  Chrome reflective shimmer effect
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
                        .onAppear {
                            viewWidth = geometry.size.width
                        }
                }
            )
            .overlay(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0),
                        Color.white.opacity(0.2),
                        Color.white.opacity(0.4),
                        Color.white.opacity(0.2),
                        Color.white.opacity(0)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .offset(x: shimmerOffset * (viewWidth > 0 ? viewWidth : 400))
                .mask(content)
                .blendMode(.overlay)
                .opacity(isAnimated ? 1 : 0.5)
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
    /// Adds a chrome shimmer effect to the view
    /// - Parameter animated: Whether the shimmer should animate
    func chromeEffect(animated: Bool = true) -> some View {
        modifier(ChromeEffectModifier(isAnimated: animated))
    }
}

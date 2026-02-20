//
//  SwipeGestureHandler.swift
//  ledger
//
//  Swipe gesture system for navigation
//

import SwiftUI

struct SwipeGestureModifier: ViewModifier {
    let onSwipeUp: (() -> Void)?
    let onSwipeDown: (() -> Void)?
    let onSwipeLeft: (() -> Void)?
    let onSwipeRight: (() -> Void)?

    let threshold: CGFloat
    let velocity: CGFloat

    @State private var dragOffset = CGSize.zero
    @State private var isDragging = false

    init(
        threshold: CGFloat = 50,
        velocity: CGFloat = 300,
        onSwipeUp: (() -> Void)? = nil,
        onSwipeDown: (() -> Void)? = nil,
        onSwipeLeft: (() -> Void)? = nil,
        onSwipeRight: (() -> Void)? = nil
    ) {
        self.threshold = threshold
        self.velocity = velocity
        self.onSwipeUp = onSwipeUp
        self.onSwipeDown = onSwipeDown
        self.onSwipeLeft = onSwipeLeft
        self.onSwipeRight = onSwipeRight
    }

    func body(content: Content) -> some View {
        content
            .offset(y: isDragging ? min(max(dragOffset.height, -100), 100) * 0.1 : 0)
            .gesture(
                DragGesture(minimumDistance: 20)
                    .onChanged { value in
                        withAnimation(.gestureSpring) {
                            isDragging = true
                            dragOffset = value.translation
                        }
                    }
                    .onEnded { value in
                        withAnimation(.snapBack) {
                            isDragging = false
                            dragOffset = .zero
                        }

                        handleSwipe(translation: value.translation, predictedEndTranslation: value.predictedEndTranslation)
                    }
            )
    }

    private func handleSwipe(translation: CGSize, predictedEndTranslation: CGSize) {
        // Calculate velocity
        let velocityX = abs(predictedEndTranslation.width - translation.width)
        let velocityY = abs(predictedEndTranslation.height - translation.height)

        // Determine direction based on translation and velocity
        let isHorizontal = abs(translation.width) > abs(translation.height)
        let isVertical = abs(translation.height) > abs(translation.width)

        // Horizontal swipes
        if isHorizontal {
            if translation.width < -threshold || velocityX > velocity {
                // Swipe left
                onSwipeLeft?()
            } else if translation.width > threshold || velocityX > velocity {
                // Swipe right
                onSwipeRight?()
            }
        }

        // Vertical swipes
        if isVertical {
            if translation.height < -threshold || velocityY > velocity {
                // Swipe up
                onSwipeUp?()
            } else if translation.height > threshold || velocityY > velocity {
                // Swipe down
                onSwipeDown?()
            }
        }
    }
}

extension View {
    /// Adds swipe gesture handlers to the view
    /// - Parameters:
    ///   - threshold: Minimum distance to trigger swipe (default: 50)
    ///   - velocity: Minimum velocity to trigger swipe (default: 300)
    ///   - up: Handler for upward swipe
    ///   - down: Handler for downward swipe
    ///   - left: Handler for leftward swipe
    ///   - right: Handler for rightward swipe
    func onSwipe(
        threshold: CGFloat = 50,
        velocity: CGFloat = 300,
        up: (() -> Void)? = nil,
        down: (() -> Void)? = nil,
        left: (() -> Void)? = nil,
        right: (() -> Void)? = nil
    ) -> some View {
        modifier(SwipeGestureModifier(
            threshold: threshold,
            velocity: velocity,
            onSwipeUp: up,
            onSwipeDown: down,
            onSwipeLeft: left,
            onSwipeRight: right
        ))
    }
}

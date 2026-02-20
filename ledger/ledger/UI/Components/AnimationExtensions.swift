//
//  AnimationExtensions.swift
//  ledger
//
//  Created for Ledger Phase 3
//  Enhanced for Modern UI Redesign
//

import SwiftUI

extension Animation {
    // Original animations
    static let ledgerSpring = Animation.spring(response: 0.35, dampingFraction: 0.75)
    static let ledgerFast = Animation.easeOut(duration: 0.2)

    // Glassmorphic animations
    static let glassMorphSpring = Animation.spring(response: 0.4, dampingFraction: 0.7)
    static let glassPress = Animation.spring(response: 0.3, dampingFraction: 0.6)

    // Chrome shimmer
    static let chromeShimmer = Animation.linear(duration: 2.5).repeatForever(autoreverses: false)

    // Glow animations
    static let glowPulse = Animation.easeInOut(duration: 2).repeatForever(autoreverses: true)
    static let subtleGlow = Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true)

    // Gesture-driven animations
    static let gestureSpring = Animation.interpolatingSpring(stiffness: 300, damping: 30)
    static let snapBack = Animation.spring(response: 0.3, dampingFraction: 0.8)

    // Splash screen animations
    static let splash = Animation.easeInOut(duration: DesignSystem.Duration.splash)
    static let splashFade = Animation.easeInOut(duration: DesignSystem.Duration.splashTransition)

    // Page transitions
    static let pageSlide = Animation.spring(response: 0.4, dampingFraction: 0.85)
    static let pageSnap = Animation.spring(response: 0.25, dampingFraction: 0.9)
}


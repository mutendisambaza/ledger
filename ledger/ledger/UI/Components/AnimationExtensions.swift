//
//  AnimationExtensions.swift
//  ledger
//
//  Wealthsimple-grade motion system.
//  Motion confirms, never entertains — transitions are fast and purposeful (180–320ms).
//

import SwiftUI

extension Animation {

    // MARK: - Page Transitions
    // Spring for entry (weighted, physical), easeIn for exit (fast, clean).

    /// Page entry — weighted spring, slight bounce for physicality.
    static let pageEntry = Animation.spring(duration: 0.32, bounce: 0.08)
    /// Page exit — fast easeIn, gets out of the way.
    static let pageExit = Animation.easeIn(duration: 0.18)

    // Legacy aliases — map to new standard (avoids touching all callsites)
    static let pageSlide = Animation.pageEntry
    static let pageSnap = Animation.spring(duration: 0.25, bounce: 0.0)

    // MARK: - State Changes
    // Component-level transitions — no bounce for toggles, subtle bounce for alerts.

    /// Toggle / select state — snappy, zero bounce.
    static let stateToggle = Animation.spring(duration: 0.22, bounce: 0.0)
    /// Amount / number update — interpolating spring for smooth count feel.
    static let amountUpdate = Animation.interpolatingSpring(stiffness: 200, damping: 20)
    /// Alert / error appearance — slight bounce signals importance.
    static let alertAppear = Animation.spring(duration: 0.28, bounce: 0.12)

    // Legacy aliases
    static let ledgerSpring = Animation.stateToggle
    static let glassMorphSpring = Animation.stateToggle
    static let glassPress = Animation.spring(duration: 0.20, bounce: 0.0)
    static let ledgerFast = Animation.easeOut(duration: 0.18)
    static let snapBack = Animation.spring(duration: 0.28, bounce: 0.05)
    static let gestureSpring = Animation.interpolatingSpring(stiffness: 300, damping: 28)

    // MARK: - Ambient / Looping

    /// Chrome shimmer — linear loop, no reverse.
    static let chromeShimmer = Animation.linear(duration: 2.5).repeatForever(autoreverses: false)
    /// Subtle breathing for ambient presence — slow, barely noticeable.
    static let glowPulse = Animation.easeInOut(duration: 3.0).repeatForever(autoreverses: true)
    static let subtleGlow = Animation.easeInOut(duration: 2.5).repeatForever(autoreverses: true)

    // MARK: - Splash

    static let splash = Animation.easeInOut(duration: DesignSystem.Duration.splash)
    static let splashFade = Animation.easeInOut(duration: DesignSystem.Duration.splashTransition)

    // MARK: - Staggered List
    // Base: 0ms, increment: 55ms per row. Entry slides from bottom, never from top.

    /// Returns a staggered spring animation for list rows.
    /// - Parameter index: Zero-based row index.
    static func listRow(_ index: Int) -> Animation {
        .spring(duration: 0.32, bounce: 0.06)
            .delay(Double(index) * 0.055)
    }
}

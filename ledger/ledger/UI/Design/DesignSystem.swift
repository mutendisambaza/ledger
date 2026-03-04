//
//  DesignSystem.swift
//  ledger
//
//  Single source of truth — Wealthsimple-grade design tokens
//  Never hardcode values in views. Every color, size, and duration lives here.
//

import SwiftUI

enum DesignSystem {

    // MARK: - Colors

    enum Colors {
        // Primary Palette
        static var sageGreen: Color { accent }
        static let chromeSilver = Color(hex: "C0C0C0")
        static var glowingWhite: Color {
            AppConfig.Defaults.isDarkMode() ? .white : Color(hex: "0B0B0C")
        }
        static var accent: Color {
            Color(hex: AppConfig.Defaults.currentAccentHex())
        }

        // Backgrounds
        static var black: Color {
            AppConfig.Defaults.isDarkMode() ? Color(hex: "0B0B0C") : Color(hex: "F5F5F5")
        }
        static var greyWhite: Color {
            AppConfig.Defaults.isDarkMode() ? Color(hex: "F5F5F5") : Color(hex: "0B0B0C")
        }
        static var darkGrey: Color {
            AppConfig.Defaults.isDarkMode() ? Color(hex: "3A3A3A") : Color(hex: "E5E5E5")
        }
        static var mediumGrey: Color {
            AppConfig.Defaults.isDarkMode() ? Color(hex: "6B6B6B") : Color(hex: "B5B5B5")
        }

        // ── Semantic colors ────────────────────────────────────────
        /// Wealthsimple green — trustworthy, not neon.
        static let successGreen = Color(hex: "4CAF7D")
        static let warningColor = Color(hex: "F5A623")
        /// Danger / failure — unchanged.
        static let failedRed = Color(hex: "FF6B6B")
        static var successGreen: Color { accent }

        // ── Opacity helpers ────────────────────────────────────────
        static func sage(_ opacity: Double) -> Color {
            sageGreen.opacity(opacity)
        }

        static func chrome(_ opacity: Double) -> Color {
            chromeSilver.opacity(opacity)
        }

        /// White with opacity — use for glow containers, never for text.
        static func glow(_ opacity: Double) -> Color {
            Color.white.opacity(opacity)
        }
    }

    // MARK: - Typography
    // Typography does the heavy lifting — hierarchy through weight and size, not color noise.

    enum Typography {
        // Display
        static let splashLogo: Font = .system(size: 72, weight: .bold, design: .rounded)
        static let splashText: Font = .system(size: 56, weight: .light)
        /// Hero amount — monospaced prevents layout shift during count animations.
        static let heroAmount: Font = .system(size: 64, weight: .semibold, design: .monospaced)
        static let restingAmount: Font = .system(size: 72, weight: .light, design: .monospaced)

        // Headers
        static let calendarHeader: Font = .system(size: 34, weight: .semibold)
        static let sectionHeader: Font = .system(size: 26, weight: .semibold)
        static let cardHeader: Font = .system(size: 18, weight: .semibold)

        // Body
        static let body: Font = .system(size: 16, weight: .regular)
        static let bodyMedium: Font = .system(size: 16, weight: .medium)
        static let caption: Font = .system(size: 14, weight: .regular)
        static let captionMedium: Font = .system(size: 14, weight: .medium)
        static let captionBold: Font = .system(size: 14, weight: .semibold)
        static let micro: Font = .system(size: 12, weight: .regular)

        // Amounts — monospaced non-negotiable for alignment and count animations
        static let amountLarge: Font = .system(size: 48, weight: .semibold, design: .monospaced)
        static let amountMedium: Font = .system(size: 32, weight: .medium, design: .monospaced)
        static let amountSmall: Font = .system(size: 22, weight: .regular, design: .monospaced)
    }

    // MARK: - Spacing
    // Generous whitespace makes numbers feel important.

    enum Spacing {
        static let xxxs: CGFloat = 4
        static let xxs: CGFloat = 8
        static let xs: CGFloat = 12
        static let sm: CGFloat = 16
        static let md: CGFloat = 24
        static let lg: CGFloat = 32
        static let xl: CGFloat = 48
        static let xxl: CGFloat = 64
        static let xxxl: CGFloat = 96
    }

    // MARK: - Corner Radius

    enum CornerRadius {
        static let xs: CGFloat = 8
        static let sm: CGFloat = 12
        static let md: CGFloat = 16
        static let lg: CGFloat = 20
        static let xl: CGFloat = 28
        static let full: CGFloat = 9999
    }

    // MARK: - Effects
    // Restraint is the upgrade. Max one glow per scroll viewport.

    enum Effects {
        // Glow radii — ambient only, never spotlight
        static let glowRadius: CGFloat = 10          // Component-level glow
        static let glowRadiusLarge: CGFloat = 20     // Hero element glow (hero amount)
        static let glowRadiusXL: CGFloat = 50        // Ambient background glow (use sparingly)

        // Glow opacity ceilings — 0.12–0.18 range is ambient, not decorative
        static let glowOpacityAmbient: Double = 0.15
        static let glowOpacitySubtle: Double = 0.10

        // Blur radii
        static let blurThin: CGFloat = 8
        static let blurMedium: CGFloat = 16
        static let blurThick: CGFloat = 24

        // Shadow — for light mode elevation, not dark mode glow
        static let shadowColor = Color.black.opacity(0.12)
        static let shadowRadius: CGFloat = 12
        static let shadowOffset: CGSize = CGSize(width: 0, height: 4)

        // Border — whisper-thin, just enough depth
        static let borderWidth: CGFloat = 0.5

        // Chrome gradient — muted, not theatrical
        static let chromeGradient = LinearGradient(
            colors: [
                Colors.chrome(0.06),
                Colors.chrome(0.18),
                Colors.chrome(0.10),
                Colors.chrome(0.06)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        // Sage gradient — for selected states
        static let sageGradient = LinearGradient(
            colors: [Colors.sage(0.18), Colors.sage(0.10)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        // Glass material — use sparingly; prefer solid surface colors
        static let glassMaterial = Material.ultraThinMaterial
    }

    // MARK: - Animation Durations

    enum Duration {
        static let instant: Double = 0.15
        static let fast: Double = 0.18        // Exit transitions
        static let normal: Double = 0.32      // Entry transitions
        static let slow: Double = 0.5
        static let count: Double = 0.6        // Hero number counting
        static let splash: Double = 4.0
        static let splashTransition: Double = 0.5
    }
}

//
//  DesignSystem.swift
//  ledger
//
//  Modern Design System - Sage Green, Chrome Silver, Glowing White
//

import SwiftUI

enum DesignSystem {

    // MARK: - Colors

    enum Colors {
        // Primary Palette
        static let sageGreen = Color(hex: "B4C7B8")
        static let chromeSilver = Color(hex: "C0C0C0")
        static let glowingWhite = Color.white

        // Backgrounds
        static let black = Color(hex: "0B0B0C")
        static let greyWhite = Color(hex: "F5F5F5")
        static let darkGrey = Color(hex: "3A3A3A")
        static let mediumGrey = Color(hex: "6B6B6B")

        // Accent Colors
        static let failedRed = Color(hex: "FF6B6B")
        static let successGreen = sageGreen

        // Transparency variations
        static func sage(_ opacity: Double) -> Color {
            sageGreen.opacity(opacity)
        }

        static func chrome(_ opacity: Double) -> Color {
            chromeSilver.opacity(opacity)
        }

        static func glow(_ opacity: Double) -> Color {
            glowingWhite.opacity(opacity)
        }
    }

    // MARK: - Typography

    enum Typography {
        // Display
        static let splashLogo: Font = .system(size: 72, weight: .bold, design: .rounded)
        static let splashText: Font = .system(size: 56, weight: .light)
        static let heroAmount: Font = .system(size: 64, weight: .bold, design: .rounded)
        static let restingAmount: Font = .system(size: 72, weight: .light, design: .monospaced)

        // Headers
        static let calendarHeader: Font = .system(size: 36, weight: .medium)
        static let sectionHeader: Font = .system(size: 28, weight: .semibold)
        static let cardHeader: Font = .system(size: 20, weight: .semibold)

        // Body
        static let body: Font = .system(size: 16, weight: .regular)
        static let bodyMedium: Font = .system(size: 16, weight: .medium)
        static let caption: Font = .system(size: 14, weight: .regular)
        static let captionBold: Font = .system(size: 14, weight: .bold)

        // Amounts
        static let amountLarge: Font = .system(size: 48, weight: .bold, design: .monospaced)
        static let amountMedium: Font = .system(size: 32, weight: .semibold, design: .monospaced)
        static let amountSmall: Font = .system(size: 24, weight: .medium, design: .monospaced)
    }

    // MARK: - Spacing

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
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let full: CGFloat = 9999
    }

    // MARK: - Effects

    enum Effects {
        // Glow Configurations
        static let glowRadius: CGFloat = 12
        static let glowRadiusLarge: CGFloat = 24
        static let glowRadiusXL: CGFloat = 40

        // Blur Radii
        static let blurThin: CGFloat = 8
        static let blurMedium: CGFloat = 16
        static let blurThick: CGFloat = 24

        // Shadow Configurations
        static let shadowColor = Colors.glow(0.3)
        static let shadowRadius: CGFloat = 16
        static let shadowOffset: CGSize = CGSize(width: 0, height: 8)

        // Chrome Gradient
        static let chromeGradient = LinearGradient(
            colors: [
                Colors.chrome(0.1),
                Colors.chrome(0.4),
                Colors.chrome(0.8),
                Colors.chrome(0.4),
                Colors.chrome(0.1)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        // Sage Gradient
        static let sageGradient = LinearGradient(
            colors: [
                Colors.sage(0.3),
                Colors.sage(0.6),
                Colors.sage(1.0)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        // Glass Material
        static let glassMaterial = Material.ultraThinMaterial
    }

    // MARK: - Animation Durations

    enum Duration {
        static let instant: Double = 0.15
        static let fast: Double = 0.25
        static let normal: Double = 0.35
        static let slow: Double = 0.5
        static let splash: Double = 4.0
        static let splashTransition: Double = 0.5
    }
}

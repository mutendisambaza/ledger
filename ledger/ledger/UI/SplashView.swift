//
//  SplashView.swift
//  ledger
//
//  Splash screen: 4s logo → 4s "Ledger" text → fade to app
//

import SwiftUI

struct SplashView: View {
    @ObservedObject var authManager: GoogleAuthManager
    @ObservedObject var router: NavigationRouter

    @State private var phase: SplashPhase = .logo
    @State private var logoOpacity: Double = 0
    @State private var logoScale: CGFloat = 0.8
    @State private var textOpacity: Double = 0
    @State private var textScale: CGFloat = 0.9

    enum SplashPhase {
        case logo
        case text
        case complete
    }

    var body: some View {
        ZStack {
            // Background
            DesignSystem.Colors.black
                .ignoresSafeArea()

            // Logo Phase
            if phase == .logo {
                VStack(spacing: 0) {
                    // App icon/logo
                    RoundedRectangle(cornerRadius: 24)
                        .fill(
                            LinearGradient(
                                colors: [
                                    DesignSystem.Colors.sageGreen,
                                    DesignSystem.Colors.sageGreen.opacity(0.7)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                        .overlay(
                            Text("L")
                                .font(.system(size: 64, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        )
                        .glow(color: DesignSystem.Colors.sageGreen, radius: 32, intensity: 0.8)
                        .scaleEffect(logoScale)
                        .opacity(logoOpacity)
                }
            }

            // Text Phase
            if phase == .text {
                GlowingText(
                    text: "Ledger",
                    font: DesignSystem.Typography.splashText,
                    color: DesignSystem.Colors.glowingWhite,
                    glowColor: DesignSystem.Colors.sageGreen,
                    isPulsing: true
                )
                .scaleEffect(textScale)
                .opacity(textOpacity)
            }
        }
        .onAppear {
            startSplashSequence()
        }
    }

    private func startSplashSequence() {
        // Phase 1: Logo (0-4s)
        withAnimation(.splash) {
            logoOpacity = 1
            logoScale = 1.0
        }

        // Phase 2: Transition to text (4-4.5s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            withAnimation(.splashFade) {
                logoOpacity = 0
                logoScale = 1.2
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                phase = .text

                withAnimation(.splash) {
                    textOpacity = 1
                    textScale = 1.0
                }
            }
        }

        // Phase 3: Transition to app (8-8.5s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 8.0) {
            withAnimation(.splashFade) {
                textOpacity = 0
                textScale = 1.1
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                phase = .complete
                completeSplash()
            }
        }
    }

    private func completeSplash() {
        if authManager.isAuthenticated {
            router.showResting()
        } else {
            router.showSignIn()
        }
    }
}

#Preview {
    SplashView(
        authManager: GoogleAuthManager(),
        router: NavigationRouter()
    )
}

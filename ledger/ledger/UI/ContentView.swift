//
//  ContentView.swift
//  ledger
//
//  Main navigation controller with screen routing and splash
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var store: LedgerStore
    @StateObject private var authManager = GoogleAuthManager()
    @StateObject private var router = NavigationRouter()

    var body: some View {
        ZStack {
            // Background
            DesignSystem.Colors.black
                .ignoresSafeArea()

            // Screen routing
            Group {
                switch router.currentScreen {
                case .splash:
                    SplashView(
                        authManager: authManager,
                        router: router
                    )

                case .signIn:
                    SignInView(authManager: authManager)
                        .transition(.opacity)

                case .resting:
                    RestingView(authManager: authManager)
                        .transition(.opacity)

                case .home:
                    HomeView(authManager: authManager)
                        .transition(.move(edge: .bottom).combined(with: .opacity))

                case .calendar:
                    CalendarView()
                        .transition(.move(edge: .trailing).combined(with: .opacity))

                case .settings:
                    SettingsView(authManager: authManager, store: store)
                        .transition(.opacity)
                }
            }
            .animation(Animation.pageSlide, value: router.currentScreen)
        }
        .environmentObject(router)
        .onChange(of: authManager.isAuthenticated) { oldValue, newValue in
            // Handle authentication state changes
            if newValue {
                if router.currentScreen == .signIn || router.currentScreen == .splash {
                    router.navigate(to: .resting)
                }
            } else if router.currentScreen != .splash {
                router.navigate(to: .signIn)
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(LedgerStore.shared)
}

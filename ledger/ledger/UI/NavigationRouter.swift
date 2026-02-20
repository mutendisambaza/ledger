//
//  NavigationRouter.swift
//  ledger
//
//  Navigation state management for app screens
//

import SwiftUI
import Combine

enum AppScreen: Equatable {
    case splash
    case signIn
    case resting
    case home
    case calendar
    case settings
}

class NavigationRouter: ObservableObject {
    @Published var currentScreen: AppScreen = .splash
    @Published var previousScreen: AppScreen?

    // Track navigation history for back gestures
    private var navigationStack: [AppScreen] = []

    @MainActor
    func navigate(to screen: AppScreen, animated: Bool = true) {
        withAnimation(animated ? Animation.pageSlide : nil) {
            previousScreen = currentScreen
            navigationStack.append(currentScreen)
            currentScreen = screen
        }
    }

    @MainActor
    func goBack(animated: Bool = true) {
        guard let previous = navigationStack.popLast() else { return }

        withAnimation(animated ? Animation.pageSlide : nil) {
            previousScreen = currentScreen
            currentScreen = previous
        }
    }

    func reset(to screen: AppScreen = .splash) {
        navigationStack.removeAll()
        previousScreen = nil
        currentScreen = screen
    }

    // Convenience navigation methods
    func showSplash() {
        navigate(to: .splash)
    }

    func showSignIn() {
        navigate(to: .signIn)
    }

    func showResting() {
        navigate(to: .resting)
    }

    func showHome() {
        navigate(to: .home)
    }

    func showCalendar() {
        navigate(to: .calendar)
    }

    func showSettings() {
        navigate(to: .settings)
    }
}

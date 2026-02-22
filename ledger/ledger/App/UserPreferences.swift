//
//  UserPreferences.swift
//  ledger
//
//  User-configurable preferences — persisted via UserDefaults.
//  Inject as @EnvironmentObject so all views read the same instance.
//

import SwiftUI
import Combine

// MARK: - Accent Color

enum AccentColorOption: String, CaseIterable, Identifiable {
    case sage     = "sage"
    case blue     = "blue"
    case coral    = "coral"
    case lavender = "lavender"

    var id: String { rawValue }

    var label: String {
        switch self {
        case .sage:     return "Sage"
        case .blue:     return "Blue"
        case .coral:    return "Coral"
        case .lavender: return "Lavender"
        }
    }

    var color: Color {
        switch self {
        case .sage:     return DesignSystem.Colors.sageGreen
        case .blue:     return DesignSystem.Colors.blue
        case .coral:    return DesignSystem.Colors.coral
        case .lavender: return DesignSystem.Colors.lavender
        }
    }
}

// MARK: - Appearance Mode

enum AppearanceMode: String, CaseIterable, Identifiable {
    case system = "system"
    case light  = "light"
    case dark   = "dark"

    var id: String { rawValue }

    var label: String {
        switch self {
        case .system: return "Auto"
        case .light:  return "Light"
        case .dark:   return "Dark"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light:  return .light
        case .dark:   return .dark
        }
    }
}

// MARK: - UserPreferences

final class UserPreferences: ObservableObject {

    private let defaults = UserDefaults.standard
    private let accentKey = "pref_accentColor"
    private let appearanceKey = "pref_appearanceMode"

    @Published var accentColor: AccentColorOption {
        didSet { defaults.set(accentColor.rawValue, forKey: accentKey) }
    }

    @Published var appearanceMode: AppearanceMode {
        didSet { defaults.set(appearanceMode.rawValue, forKey: appearanceKey) }
    }

    init() {
        let savedAccent = defaults.string(forKey: "pref_accentColor")
        accentColor = AccentColorOption(rawValue: savedAccent ?? "") ?? .sage

        let savedAppearance = defaults.string(forKey: "pref_appearanceMode")
        appearanceMode = AppearanceMode(rawValue: savedAppearance ?? "") ?? .dark
    }

    /// Convenience: the current accent Color.
    var accent: Color { accentColor.color }

    /// Convenience: the preferred ColorScheme (nil = follow system).
    var colorScheme: ColorScheme? { appearanceMode.colorScheme }
}

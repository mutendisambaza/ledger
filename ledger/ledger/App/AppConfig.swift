//
//  AppConfig.swift
//  ledger
//
//  Created for Ledger Phase 1
//

import Foundation

enum AppConfig {
    static let appGroupId = "group.com.taurai.ledger"
    static let suiteName = appGroupId
    
    enum Keys {
        static let todayTotalCents = "today_total_cents"
        static let lastUpdated = "last_updated_iso"
        static let todayDate = "today_date_iso"
        static let transactions = "transactions_json"
        static let selectedCurrencyCode = "selected_currency_code"
        static let selectedAccentHex = "selected_accent_hex"
        static let isDarkMode = "is_dark_mode"
    }
    
    enum Defaults {
        static let currency = "CAD"
        static let supportedCurrencies = ["CAD", "USD"]
        static let defaultAccentHex = "B4C7B8"
        static let supportedAccentHexes = [
            "B4C7B8", // Sage
            "6FA8FF", // Blue
            "FF8F6B", // Coral
            "D1B3FF"  // Lavender
        ]

        static func currentCurrencyCode(
            userDefaults: UserDefaults? = UserDefaults(suiteName: AppConfig.suiteName)
        ) -> String {
            let stored = userDefaults?.string(forKey: AppConfig.Keys.selectedCurrencyCode)
            if let code = stored, supportedCurrencies.contains(code) {
                return code
            }
            return currency
        }

        static func setCurrencyCode(
            _ code: String,
            userDefaults: UserDefaults? = UserDefaults(suiteName: AppConfig.suiteName)
        ) {
            guard supportedCurrencies.contains(code) else { return }
            userDefaults?.set(code, forKey: AppConfig.Keys.selectedCurrencyCode)
        }

        static func symbol(for code: String) -> String {
            switch code {
            case "USD":
                return "$"
            case "CAD":
                return "CA$"
            default:
                return "$"
            }
        }

        static func currentCurrencySymbol(
            userDefaults: UserDefaults? = UserDefaults(suiteName: AppConfig.suiteName)
        ) -> String {
            symbol(for: currentCurrencyCode(userDefaults: userDefaults))
        }

        static func currentAccentHex(
            userDefaults: UserDefaults? = UserDefaults(suiteName: AppConfig.suiteName)
        ) -> String {
            let stored = userDefaults?.string(forKey: AppConfig.Keys.selectedAccentHex)
            if let stored, supportedAccentHexes.contains(stored) {
                return stored
            }
            return defaultAccentHex
        }

        static func setAccentHex(
            _ hex: String,
            userDefaults: UserDefaults? = UserDefaults(suiteName: AppConfig.suiteName)
        ) {
            guard supportedAccentHexes.contains(hex) else { return }
            userDefaults?.set(hex, forKey: AppConfig.Keys.selectedAccentHex)
        }

        static func isDarkMode(
            userDefaults: UserDefaults? = UserDefaults(suiteName: AppConfig.suiteName)
        ) -> Bool {
            guard let userDefaults else { return true }
            if userDefaults.object(forKey: AppConfig.Keys.isDarkMode) == nil {
                return true
            }
            return userDefaults.bool(forKey: AppConfig.Keys.isDarkMode)
        }

        static func setDarkMode(
            _ enabled: Bool,
            userDefaults: UserDefaults? = UserDefaults(suiteName: AppConfig.suiteName)
        ) {
            userDefaults?.set(enabled, forKey: AppConfig.Keys.isDarkMode)
        }
    }

    enum GoogleOAuth {
        static let authScope = "https://www.googleapis.com/auth/gmail.readonly"

        static func clientID() -> String? {
            Bundle.main.object(forInfoDictionaryKey: "GIDClientID") as? String
        }

        static func assertConfigurationIsValid(file: StaticString = #fileID, line: UInt = #line) {
            guard let clientID = clientID(), !clientID.isEmpty else {
                assertionFailure("Missing GIDClientID in Info.plist", file: file, line: line)
                return
            }

            let expectedScheme = "com.googleusercontent.apps.\(clientID.replacingOccurrences(of: ".apps.googleusercontent.com", with: ""))"
            let urlTypes = Bundle.main.object(forInfoDictionaryKey: "CFBundleURLTypes") as? [[String: Any]]
            let schemes = urlTypes?
                .compactMap { $0["CFBundleURLSchemes"] as? [String] }
                .flatMap { $0 } ?? []

            let hasScheme = schemes.contains(where: { $0.caseInsensitiveCompare(expectedScheme) == .orderedSame })
            assert(hasScheme, "OAuth URL scheme drift detected between GIDClientID and CFBundleURLTypes", file: file, line: line)
        }
    }

    enum Supabase {
        static func urlString() -> String? {
            Bundle.main.object(forInfoDictionaryKey: "SUPABASE_URL") as? String
        }

        static func publishableKey() -> String? {
            Bundle.main.object(forInfoDictionaryKey: "SUPABASE_PUBLISHABLE_KEY") as? String
        }

        static func assertConfigurationIsValid(file: StaticString = #fileID, line: UInt = #line) {
            guard let rawURL = urlString(), let parsedURL = URL(string: rawURL), parsedURL.scheme != nil else {
                assertionFailure("Missing or invalid SUPABASE_URL in Info.plist", file: file, line: line)
                return
            }

            guard let key = publishableKey(), !key.isEmpty else {
                assertionFailure("Missing SUPABASE_PUBLISHABLE_KEY in Info.plist", file: file, line: line)
                return
            }
        }
    }
}

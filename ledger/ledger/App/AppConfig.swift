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
    }
    
    enum Defaults {
        static let currency = "CAD"
        static let currencySymbol = "$"
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
}

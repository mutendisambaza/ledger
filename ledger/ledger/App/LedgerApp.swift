//
//  LedgerApp.swift
//  ledger
//

import SwiftUI

@main
struct LedgerApp: App {
    @StateObject private var store = LedgerStore.shared
    @AppStorage(
        AppConfig.Keys.selectedAccentHex,
        store: UserDefaults(suiteName: AppConfig.suiteName)
    ) private var selectedAccentHex: String = AppConfig.Defaults.defaultAccentHex
    @AppStorage(
        AppConfig.Keys.isDarkMode,
        store: UserDefaults(suiteName: AppConfig.suiteName)
    ) private var isDarkMode: Bool = true
    
    init() {
        _ = SupabaseManager.shared.client
        LedgerStore.shared.syncToWidget()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .tint(Color(hex: selectedAccentHex))
                .preferredColorScheme(isDarkMode ? .dark : .light)
        }
    }
}

//
//  LedgerApp.swift
//  ledger
//

import SwiftUI

@main
struct LedgerApp: App {
    @StateObject private var store = LedgerStore.shared
    @StateObject private var prefs = UserPreferences()

    init() {
        _ = SupabaseManager.shared.client
        LedgerStore.shared.syncToWidget()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .environmentObject(prefs)
                .preferredColorScheme(prefs.colorScheme)
        }
    }
}

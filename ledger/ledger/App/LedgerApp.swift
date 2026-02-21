//
//  LedgerApp.swift
//  ledger
//
//  Created for Ledger Phase 1
//

import SwiftUI

@main
struct LedgerApp: App {
    @StateObject private var store = LedgerStore.shared
    
    init() {
        _ = SupabaseManager.shared.client
        // Sync initial state to widget on launch
        LedgerStore.shared.syncToWidget()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}

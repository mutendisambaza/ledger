//
//  SettingsView.swift
//  ledger
//
//  Created for Ledger Phase 3
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var authManager: GoogleAuthManager
    @ObservedObject var store: LedgerStore
    @Environment(\.dismiss) var dismiss
    @State private var showClearConfirm = false
    @State private var appeared = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                Color(hex: "0B0B0C").ignoresSafeArea()
                
                List {
                    // Account section
                    Section {
                        if let email = authManager.userEmail {
                            HStack {
                                Circle()
                                    .fill(Color(hex: "3B82F6").opacity(0.2))
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Text(String(email.prefix(1)).uppercased())
                                            .font(.headline)
                                            .foregroundColor(Color(hex: "3B82F6"))
                                    )
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Connected")
                                        .font(.caption)
                                        .foregroundColor(Color(hex: "A1A1AA"))
                                    Text(email)
                                        .font(.subheadline)
                                        .foregroundColor(.white)
                                }
                            }
                            .listRowBackground(Color(hex: "171717"))
                        }
                        
                        Button(action: {
                            withAnimation(.ledgerSpring) {
                                authManager.signOut()
                            }
                            dismiss()
                        }) {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                Text("Disconnect")
                            }
                            .foregroundColor(.red)
                        }
                        .listRowBackground(Color(hex: "171717"))
                    } header: {
                        Text("Account")
                    }
                    
                    // Data section
                    Section {
                        Button(action: { showClearConfirm = true }) {
                            HStack {
                                Image(systemName: "trash")
                                Text("Clear All Data")
                            }
                            .foregroundColor(.red)
                        }
                        .listRowBackground(Color(hex: "171717"))
                    } header: {
                        Text("Data")
                    }
                    
                    // About section
                    Section {
                        HStack {
                            Text("Ledger")
                                .foregroundColor(.white)
                            Spacer()
                            Text("by TAUR")
                                .foregroundColor(Color(hex: "A1A1AA"))
                        }
                        .listRowBackground(Color(hex: "171717"))
                        
                        HStack {
                            Text("Version")
                                .foregroundColor(.white)
                            Spacer()
                            Text(appVersion)
                                .foregroundColor(Color(hex: "A1A1AA"))
                        }
                        .listRowBackground(Color(hex: "171717"))
                    } header: {
                        Text("About")
                    }
                }
                .scrollContentBackground(.hidden)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .fontWeight(.medium)
                }
            }
            .alert("Clear all data?", isPresented: $showClearConfirm) {
                Button("Cancel", role: .cancel) { }
                Button("Clear", role: .destructive) {
                    withAnimation(.ledgerSpring) {
                        store.clearAll()
                    }
                }
            } message: {
                Text("This will delete all transactions and reset the widget.")
            }
        }
        .onAppear {
            withAnimation(.ledgerSpring.delay(0.1)) {
                appeared = true
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationBackground(Color(hex: "0B0B0C"))
    }
    
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
}


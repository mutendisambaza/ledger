//
//  SettingsView.swift
//  ledger
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var authManager: GoogleAuthManager
    @ObservedObject var store: LedgerStore
    @EnvironmentObject var prefs: UserPreferences
    @Environment(\.dismiss) var dismiss

    @StateObject private var limitManager = SpendLimitManager()

    @State private var showClearConfirm = false
    @State private var limitText: String = ""
    @State private var appeared = false
    @AppStorage(
        AppConfig.Keys.selectedCurrencyCode,
        store: UserDefaults(suiteName: AppConfig.suiteName)
    ) private var selectedCurrencyCode: String = AppConfig.Defaults.currency
    @AppStorage(
        AppConfig.Keys.selectedAccentHex,
        store: UserDefaults(suiteName: AppConfig.suiteName)
    ) private var selectedAccentHex: String = AppConfig.Defaults.defaultAccentHex
    @AppStorage(
        AppConfig.Keys.isDarkMode,
        store: UserDefaults(suiteName: AppConfig.suiteName)
    ) private var isDarkMode: Bool = true

    private let accentOptions: [(name: String, hex: String)] = [
        ("Sage", "B4C7B8"),
        ("Blue", "6FA8FF"),
        ("Coral", "FF8F6B"),
        ("Lavender", "D1B3FF")
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                DesignSystem.Colors.black.ignoresSafeArea()
                
                List {
                    // ── Appearance ───────────────────────────────────
                    Section {
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                            Text("Color Scheme")
                                .font(DesignSystem.Typography.caption)
                                .foregroundColor(DesignSystem.Colors.secondaryText)

                            HStack(spacing: DesignSystem.Spacing.xxxs) {
                                ForEach(AppearanceMode.allCases) { mode in
                                    AppearancePill(
                                        mode: mode,
                                        isSelected: prefs.appearanceMode == mode,
                                        accent: prefs.accent
                                    ) {
                                        withAnimation(.stateToggle) {
                                            prefs.appearanceMode = mode
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.vertical, DesignSystem.Spacing.xxs)
                        .listRowBackground(DesignSystem.Colors.surface)

                    } header: {
                        sectionHeader("Appearance")
                    }

                    // ── Accent Color ─────────────────────────────────
                    Section {
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                            Text("Accent Color")
                                .font(DesignSystem.Typography.caption)
                                .foregroundColor(DesignSystem.Colors.secondaryText)

                            HStack(spacing: DesignSystem.Spacing.sm) {
                                ForEach(AccentColorOption.allCases) { option in
                                    AccentSwatch(
                                        option: option,
                                        isSelected: prefs.accentColor == option
                                    ) {
                                        withAnimation(.stateToggle) {
                                            prefs.accentColor = option
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.vertical, DesignSystem.Spacing.xxs)
                        .listRowBackground(DesignSystem.Colors.surface)

                    } header: {
                        sectionHeader("Accent")
                    }

                    // ── Daily Limit ──────────────────────────────────
                    Section {
                        HStack {
                            Text("Daily Limit")
                                .font(DesignSystem.Typography.body)
                                .foregroundColor(DesignSystem.Colors.primaryText)

                            Spacer()

                            HStack(spacing: 4) {
                                Text("$")
                                    .font(DesignSystem.Typography.bodyMedium)
                                    .foregroundColor(DesignSystem.Colors.secondaryText)

                                TextField("0", text: $limitText)
                                    .font(DesignSystem.Typography.amountSmall)
                                    .foregroundColor(prefs.accent)
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.trailing)
                                    .frame(width: 80)
                                    .onSubmit { saveLimitFromText() }
                                    .onChange(of: limitText) { _, _ in saveLimitFromText() }
                            }
                        }
                        .listRowBackground(DesignSystem.Colors.surface)
                    } header: {
                        sectionHeader("Spending")
                    } footer: {
                        Text("Days that exceed this limit are marked on your calendar.")
                            .font(DesignSystem.Typography.micro)
                            .foregroundColor(DesignSystem.Colors.secondaryText)
                    }

                    // ── Account ──────────────────────────────────────
                    Section {
                        if let email = authManager.userEmail {
                            HStack(spacing: DesignSystem.Spacing.sm) {
                                Circle()
                                    .fill(DesignSystem.Colors.accent.opacity(0.2))
                                    .frame(width: 40, height: 40)
                                    .overlay(
                                        Text(String(email.prefix(1)).uppercased())
                                            .font(.headline)
                                            .foregroundColor(DesignSystem.Colors.accent)
                                    )
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Connected")
                                        .font(.caption)
                                        .foregroundColor(DesignSystem.Colors.chrome(0.7))
                                    Text(email)
                                        .font(.subheadline.monospaced())
                                        .foregroundColor(DesignSystem.Colors.glowingWhite)
                                }
                            }
                            .listRowBackground(DesignSystem.Colors.darkGrey.opacity(0.35))
                        }

                        Button(action: {
                            withAnimation(.stateToggle) { authManager.signOut() }
                            dismiss()
                        }) {
                            HStack(spacing: DesignSystem.Spacing.xs) {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                Text("Disconnect")
                            }
                            .foregroundColor(DesignSystem.Colors.dangerColor)
                        }
                        .listRowBackground(DesignSystem.Colors.darkGrey.opacity(0.35))
                    } header: {
                        sectionHeader("Account")
                    }

                    // ── Data ─────────────────────────────────────────
                    Section {
                        Button(action: { showClearConfirm = true }) {
                            HStack(spacing: DesignSystem.Spacing.xs) {
                                Image(systemName: "trash")
                                Text("Clear All Data")
                            }
                            .foregroundColor(DesignSystem.Colors.dangerColor)
                        }
                        .listRowBackground(DesignSystem.Colors.darkGrey.opacity(0.35))
                    } header: {
                        sectionHeader("Data")
                    }

                    Section {
                        Toggle("Dark Mode", isOn: $isDarkMode)
                            .tint(DesignSystem.Colors.accent)
                            .onChange(of: isDarkMode) { _, newValue in
                                AppConfig.Defaults.setDarkMode(newValue)
                            }
                            .listRowBackground(DesignSystem.Colors.darkGrey.opacity(0.35))

                        Picker("Accent", selection: $selectedAccentHex) {
                            ForEach(accentOptions, id: \.hex) { option in
                                Text(option.name).tag(option.hex)
                            }
                        }
                        .onChange(of: selectedAccentHex) { _, newValue in
                            AppConfig.Defaults.setAccentHex(newValue)
                        }
                        .listRowBackground(DesignSystem.Colors.darkGrey.opacity(0.35))

                        Picker("Currency", selection: $selectedCurrencyCode) {
                            ForEach(AppConfig.Defaults.supportedCurrencies, id: \.self) { code in
                                Text(code).tag(code)
                            }
                        }
                        .onChange(of: selectedCurrencyCode) { _, newValue in
                            AppConfig.Defaults.setCurrencyCode(newValue)
                        }
                        .listRowBackground(DesignSystem.Colors.darkGrey.opacity(0.35))
                    } header: {
                        Text("Appearance")
                    }
                    
                    // About section
                    Section {
                        HStack {
                            Text("Ledger")
                                .foregroundColor(DesignSystem.Colors.glowingWhite)
                            Spacer()
                            Text("by TAUR")
                                .foregroundColor(DesignSystem.Colors.chrome(0.7))
                        }
                        .listRowBackground(DesignSystem.Colors.darkGrey.opacity(0.35))
                        
                        HStack {
                            Text("Version")
                                .foregroundColor(DesignSystem.Colors.glowingWhite)
                            Spacer()
                            Text(appVersion)
                                .foregroundColor(DesignSystem.Colors.chrome(0.7))
                        }
                        .listRowBackground(DesignSystem.Colors.darkGrey.opacity(0.35))
                    } header: {
                        sectionHeader("About")
                    }
                }
                .scrollContentBackground(.hidden)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 16)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .font(DesignSystem.Typography.bodyMedium)
                        .foregroundColor(prefs.accent)
                }
            }
            .alert("Clear all data?", isPresented: $showClearConfirm) {
                Button("Cancel", role: .cancel) { }
                Button("Clear", role: .destructive) {
                    withAnimation(.stateToggle) { store.clearAll() }
                }
            } message: {
                Text("This will delete all transactions and reset the widget.")
            }
        }
        .onAppear {
            limitText = String(format: "%.2f", Double(limitManager.dailyLimitCents) / 100.0)
            withAnimation(.pageEntry.delay(0.1)) { appeared = true }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationBackground(DesignSystem.Colors.black)
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
}

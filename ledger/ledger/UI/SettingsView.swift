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

    var body: some View {
        NavigationView {
            ZStack {
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
                                    .fill(prefs.accent.opacity(0.12))
                                    .frame(width: 36, height: 36)
                                    .overlay(
                                        Text(String(email.prefix(1)).uppercased())
                                            .font(DesignSystem.Typography.bodyMedium)
                                            .foregroundColor(prefs.accent)
                                    )
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Connected")
                                        .font(DesignSystem.Typography.micro)
                                        .foregroundColor(DesignSystem.Colors.secondaryText)
                                    Text(email)
                                        .font(DesignSystem.Typography.body)
                                        .foregroundColor(DesignSystem.Colors.primaryText)
                                }
                            }
                            .listRowBackground(DesignSystem.Colors.surface)
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
                        .listRowBackground(DesignSystem.Colors.surface)
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
                        .listRowBackground(DesignSystem.Colors.surface)
                    } header: {
                        sectionHeader("Data")
                    }

                    // ── About ────────────────────────────────────────
                    Section {
                        HStack {
                            Text("Ledger")
                                .foregroundColor(DesignSystem.Colors.primaryText)
                            Spacer()
                            Text("by TAUR")
                                .foregroundColor(DesignSystem.Colors.secondaryText)
                        }
                        .listRowBackground(DesignSystem.Colors.surface)

                        HStack {
                            Text("Version")
                                .foregroundColor(DesignSystem.Colors.primaryText)
                            Spacer()
                            Text(appVersion)
                                .foregroundColor(DesignSystem.Colors.secondaryText)
                        }
                        .listRowBackground(DesignSystem.Colors.surface)
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

    private func saveLimitFromText() {
        guard let dollars = Double(limitText), dollars > 0 else { return }
        limitManager.setLimitFromDollars(dollars)
    }

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(DesignSystem.Typography.micro)
            .foregroundColor(DesignSystem.Colors.secondaryText)
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
}

// MARK: - AppearancePill

private struct AppearancePill: View {
    let mode: AppearanceMode
    let isSelected: Bool
    let accent: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(mode.label)
                .font(DesignSystem.Typography.captionMedium)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? DesignSystem.Colors.black : DesignSystem.Colors.secondaryText)
                .padding(.horizontal, DesignSystem.Spacing.sm)
                .padding(.vertical, 7)
                .background(
                    Group {
                        if isSelected {
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                                .fill(accent)
                        } else {
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                                .fill(DesignSystem.Colors.black)
                        }
                    }
                )
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.stateToggle, value: isSelected)
    }
}

// MARK: - AccentSwatch

private struct AccentSwatch: View {
    let option: AccentColorOption
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(option.color)
                    .frame(width: 32, height: 32)

                if isSelected {
                    Circle()
                        .strokeBorder(Color.white.opacity(0.9), lineWidth: 2)
                        .frame(width: 32, height: 32)

                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(DesignSystem.Colors.black)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .animation(.stateToggle, value: isSelected)
    }
}

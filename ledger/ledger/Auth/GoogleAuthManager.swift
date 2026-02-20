//
//  GoogleAuthManager.swift
//  ledger
//
//  Created for Ledger Phase 2
//  Updated to use Google Sign-In SDK (Phase 3)
//

import Foundation
import Combine
import UIKit
import GoogleSignIn

final class GoogleAuthManager: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var userEmail: String?

    private let clientId: String
    private let scope: String

    init() {
        // OAuth configuration from AppConfig
        // Note: Client IDs for mobile apps are public by design (embedded in app binary)
        self.clientId = AppConfig.GoogleOAuth.clientId
        self.scope = AppConfig.GoogleOAuth.authScope

        checkAuthState()
    }
    
    func signIn() async throws {
        // Get the root view controller for presenting Google Sign-In
        guard let rootViewController = getRootViewController() else {
            throw AuthError.noViewController
        }

        // Configure Google Sign-In
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientId)

        // Sign in with Google Sign-In SDK
        let result = try await GIDSignIn.sharedInstance.signIn(
            withPresenting: rootViewController,
            hint: nil,
            additionalScopes: [scope]
        )

        // Get the user and tokens
        let user = result.user
        let accessToken = user.accessToken.tokenString
        let refreshToken = user.refreshToken.tokenString

        // Store tokens in keychain
        try KeychainStore.save(key: "access_token", value: accessToken)
        try KeychainStore.save(key: "refresh_token", value: refreshToken)

        // Calculate and store expiry
        let expiry = user.accessToken.expirationDate ?? Date().addingTimeInterval(3600)
        let expiryString = ISO8601DateFormatter().string(from: expiry)
        try KeychainStore.save(key: "token_expiry", value: expiryString)

        // Update state
        await MainActor.run {
            self.isAuthenticated = true
            self.userEmail = user.profile?.email
        }
    }

    @MainActor
    private func getRootViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }),
              let rootViewController = window.rootViewController else {
            return nil
        }
        return rootViewController
    }
    
    func signOut() {
        // Sign out from Google Sign-In SDK
        GIDSignIn.sharedInstance.signOut()

        // Clear keychain
        KeychainStore.delete(key: "access_token")
        KeychainStore.delete(key: "refresh_token")
        KeychainStore.delete(key: "token_expiry")

        isAuthenticated = false
        userEmail = nil
    }
    
    func getValidAccessToken() async throws -> String {
        // Check if user is currently signed in with Google Sign-In SDK
        guard let currentUser = GIDSignIn.sharedInstance.currentUser else {
            // Try to restore previous sign-in
            if let restoredUser = try? await GIDSignIn.sharedInstance.restorePreviousSignIn() {
                // Update stored tokens
                let accessToken = restoredUser.accessToken.tokenString
                try? KeychainStore.save(key: "access_token", value: accessToken)

                let expiry = restoredUser.accessToken.expirationDate ?? Date().addingTimeInterval(3600)
                let expiryString = ISO8601DateFormatter().string(from: expiry)
                try? KeychainStore.save(key: "token_expiry", value: expiryString)

                await MainActor.run {
                    self.isAuthenticated = true
                    self.userEmail = restoredUser.profile?.email
                }

                return accessToken
            }
            throw AuthError.notAuthenticated
        }

        // Check if token needs refresh
        if currentUser.accessToken.expirationDate ?? Date() > Date().addingTimeInterval(300) {
            // Token is still valid
            return currentUser.accessToken.tokenString
        }

        // Refresh the token using Google Sign-In SDK
        try await currentUser.refreshTokensIfNeeded()
        let accessToken = currentUser.accessToken.tokenString

        // Update stored tokens
        try KeychainStore.save(key: "access_token", value: accessToken)

        let expiry = currentUser.accessToken.expirationDate ?? Date().addingTimeInterval(3600)
        let expiryString = ISO8601DateFormatter().string(from: expiry)
        try KeychainStore.save(key: "token_expiry", value: expiryString)

        return accessToken
    }
    
    // MARK: - Private

    private func checkAuthState() {
        Task {
            // Try to restore previous sign-in from Google Sign-In SDK
            if let user = try? await GIDSignIn.sharedInstance.restorePreviousSignIn() {
                await MainActor.run {
                    self.isAuthenticated = true
                    self.userEmail = user.profile?.email
                }

                // Update stored tokens
                let accessToken = user.accessToken.tokenString
                try? KeychainStore.save(key: "access_token", value: accessToken)

                let expiry = user.accessToken.expirationDate ?? Date().addingTimeInterval(3600)
                let expiryString = ISO8601DateFormatter().string(from: expiry)
                try? KeychainStore.save(key: "token_expiry", value: expiryString)
            }
        }
    }
}

// MARK: - Supporting Types

enum AuthError: Error {
    case invalidCallback
    case notAuthenticated
    case tokenExchangeFailed
    case tokenRefreshFailed
    case noViewController
}


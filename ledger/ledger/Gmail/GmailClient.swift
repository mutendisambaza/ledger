//
//  GmailClient.swift
//  ledger
//
//  Created for Ledger Phase 2
//

import Foundation

struct GmailSyncResult: Sendable {
    let fetched: Int
    let parsed: Int
    let inserted: Int
    let skipped: Int
    let errors: [String]
}

final class GmailClient {
    private let authManager: GoogleAuthManager
    private let baseURL = "https://gmail.googleapis.com/gmail/v1"
    
    init(authManager: GoogleAuthManager) {
        self.authManager = authManager
    }
    
    func listMessages(query: String, maxResults: Int = 50) async throws -> [GmailMessageRef] {
        let accessToken = try await authManager.getValidAccessToken()
        
        var components = URLComponents(string: "\(baseURL)/users/me/messages")!
        // URLComponents automatically encodes query items, but we need to ensure proper encoding
        components.queryItems = [
            URLQueryItem(name: "q", value: query.trimmingCharacters(in: .whitespacesAndNewlines)),
            URLQueryItem(name: "maxResults", value: "\(maxResults)")
        ]
        
        guard let url = components.url else {
            throw GmailError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GmailError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            let body = String(data: data, encoding: .utf8)
            if let errorString = body {
                print("Gmail API Error (\(httpResponse.statusCode)): \(errorString)")
            }
            throw GmailError.apiError(httpResponse.statusCode, body)
        }
        
        let listResponse = try JSONDecoder().decode(GmailListResponse.self, from: data)
        return listResponse.messages ?? []
    }
    
    func getMessage(id: String) async throws -> GmailMessage {
        let accessToken = try await authManager.getValidAccessToken()
        
        let url = URL(string: "\(baseURL)/users/me/messages/\(id)?format=full")!
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw GmailError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            let body = String(data: data, encoding: .utf8)
            if let errorString = body {
                print("Gmail API Error (\(httpResponse.statusCode)): \(errorString)")
            }
            throw GmailError.apiError(httpResponse.statusCode, body)
        }
        
        return try JSONDecoder().decode(GmailMessage.self, from: data)
    }
    
    /// Fetches recent receipt-like Gmail messages and per-fetch sync metadata.
    /// - Parameters:
    ///   - fetchWindowDays: Number of days to search backward, clamped to 1...30.
    ///   - maxResults: Maximum number of messages to request from Gmail.
    /// - Returns: A tuple of fetched messages and sync summary.
    func getRecentReceipts(fetchWindowDays: Int = 1, maxResults: Int = 50) async throws -> ([GmailMessage], GmailSyncResult) {
        let window = min(max(fetchWindowDays, 1), 30)
        let receiptQuery = """
        newer_than:\(window)d subject:(receipt OR order OR invoice OR "your purchase" OR "payment confirmation" OR "thank you for your order")
        """

        let messageRefs = try await listMessages(query: receiptQuery, maxResults: maxResults)

        var messages: [GmailMessage] = []
        var errors: [String] = []
        var skipped = 0

        for ref in messageRefs {
            do {
                let message = try await getMessageWithRetry(id: ref.id)
                messages.append(message)
            } catch {
                skipped += 1
                let errorMessage = "Failed to fetch message \(ref.id): \(error.localizedDescription)"
                errors.append(errorMessage)
                print(errorMessage)
            }
        }

        let result = GmailSyncResult(
            fetched: messages.count,
            parsed: 0,
            inserted: 0,
            skipped: skipped,
            errors: errors
        )
        return (messages, result)
    }

    private func getMessageWithRetry(id: String, maxRetries: Int = 2) async throws -> GmailMessage {
        var attempt = 0
        var lastError: Error?

        while attempt <= maxRetries {
            do {
                return try await getMessage(id: id)
            } catch {
                lastError = error
                if attempt == maxRetries {
                    break
                }

                let backoffSeconds = pow(2.0, Double(attempt)) * 0.5
                try? await Task.sleep(for: .seconds(backoffSeconds))
            }
            attempt += 1
        }

        throw lastError ?? GmailError.invalidResponse
    }
}

enum GmailError: Error {
    case invalidURL
    case invalidResponse
    case apiError(Int, String?)
    case decodingFailed
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid Gmail API URL"
        case .invalidResponse:
            return "Invalid response from Gmail API"
        case .apiError(let code, let message):
            var text = "Gmail API error \(code)"
            if let m = message, !m.isEmpty { text += ": \(m)" }
            if code == 404 {
                text += " — Enable Gmail API for the project, use an iOS OAuth client with bundle ID taurai.ledger, and in OAuth consent add: User support email, Privacy policy URL, and your email as Test user. See Docs/OAUTH_FIX.md."
            }
            return text
        case .decodingFailed:
            return "Failed to decode Gmail API response"
        }
    }
}

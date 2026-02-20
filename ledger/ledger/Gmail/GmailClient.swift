//
//  GmailClient.swift
//  ledger
//
//  Created for Ledger Phase 2
//

import Foundation

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
    
    func getRecentReceipts() async throws -> [GmailMessage] {
        let receiptQuery = """
        newer_than:1d (subject:receipt OR subject:order OR subject:invoice 
        OR subject:payment OR subject:confirmation OR subject:charged 
        OR subject:paid OR subject:purchase OR from:receipts)
        """
        
        let messageRefs = try await listMessages(query: receiptQuery, maxResults: 50)
        
        var messages: [GmailMessage] = []
        for ref in messageRefs {
            do {
                let message = try await getMessage(id: ref.id)
                messages.append(message)
            } catch {
                // Log error but continue with other messages
                print("Failed to fetch message \(ref.id): \(error)")
            }
        }
        
        return messages
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


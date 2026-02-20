//
//  GmailModels.swift
//  ledger
//
//  Created for Ledger Phase 2
//

import Foundation

struct GmailMessageRef: Codable {
    let id: String
    let threadId: String
}

struct GmailMessage: Codable {
    let id: String
    let snippet: String
    let payload: GmailPayload
    let internalDate: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case snippet
        case payload
        case internalDate = "internalDate"
    }
    
    var subject: String {
        payload.headers.first(where: { $0.name.lowercased() == "subject" })?.value ?? ""
    }
    
    var from: String {
        payload.headers.first(where: { $0.name.lowercased() == "from" })?.value ?? ""
    }
    
    var date: Date {
        if let internalDateString = internalDate,
           let timestamp = Int64(internalDateString) {
            return Date(timeIntervalSince1970: TimeInterval(timestamp) / 1000.0)
        }
        
        // Fallback: try to parse from Date header
        if let dateHeader = payload.headers.first(where: { $0.name.lowercased() == "date" })?.value {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE, d MMM yyyy HH:mm:ss Z"
            if let date = formatter.date(from: dateHeader) {
                return date
            }
        }
        
        return Date()
    }
    
    var bodyText: String {
        if let body = payload.body.data {
            return decodeBase64(body) ?? ""
        }
        
        // Check parts for body
        if let parts = payload.parts {
            for part in parts {
                if part.mimeType == "text/plain", let data = part.body.data {
                    return decodeBase64(data) ?? ""
                }
                // Check nested parts
                if let nestedParts = part.parts {
                    for nestedPart in nestedParts {
                        if nestedPart.mimeType == "text/plain", let data = nestedPart.body.data {
                            return decodeBase64(data) ?? ""
                        }
                    }
                }
            }
        }
        
        return snippet
    }
    
    private func decodeBase64(_ base64String: String) -> String? {
        // Gmail uses URL-safe base64, so we need to convert
        let base64 = base64String
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        
        // Add padding if needed
        let padding = base64.count % 4
        let paddedBase64 = base64 + String(repeating: "=", count: (4 - padding) % 4)
        
        guard let data = Data(base64Encoded: paddedBase64),
              let string = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return string
    }
}

struct GmailPayload: Codable {
    let headers: [GmailHeader]
    let body: GmailBody
    let parts: [GmailPart]?
}

struct GmailHeader: Codable {
    let name: String
    let value: String
}

struct GmailBody: Codable {
    let data: String?
    let size: Int
}

struct GmailPart: Codable {
    let mimeType: String
    let body: GmailBody
    let parts: [GmailPart]?
}

struct GmailListResponse: Codable {
    let messages: [GmailMessageRef]?
    let nextPageToken: String?
}


//
//  ReceiptParser.swift
//  ledger
//
//  Created for Ledger Phase 2
//

import Foundation

struct ParsedReceipt {
    let amountCents: Int
    let currency: String
    let merchant: String
    let confidence: Double // 0.0 - 1.0
}

final class ReceiptParser {
    private let merchantDomains: [String: String] = [
        "uber.com": "Uber",
        "amazon.com": "Amazon",
        "apple.com": "Apple",
        "doordash.com": "DoorDash",
        "starbucks.com": "Starbucks",
        "netflix.com": "Netflix",
        "spotify.com": "Spotify"
    ]

    func parse(message: GmailMessage) -> ParsedReceipt? {
        let bodyText = decodeHTMLEntities(in: message.bodyText)
            .replacingOccurrences(of: "C$", with: "CAD ")
        let candidates = AmountPatterns.extractAmounts(from: bodyText)
        
        guard !candidates.isEmpty else {
            return nil
        }
        
        // Score each candidate
        var scoredCandidates: [(candidate: AmountCandidate, score: Int)] = []
        
        for candidate in candidates {
            let score = scoreCandidate(candidate, context: candidate.context)
            scoredCandidates.append((candidate, score))
        }
        
        // Sort by score (descending), then by amount (descending) as tie-breaker
        scoredCandidates.sort { first, second in
            if first.score != second.score {
                return first.score > second.score
            }
            return first.candidate.amountCents > second.candidate.amountCents
        }
        
        guard let best = scoredCandidates.first else {
            return nil
        }
        
        // Convert score to confidence (0.0 - 1.0)
        // Scores can range from negative to positive, normalize to 0-1
        let minScore = scoredCandidates.map { $0.score }.min() ?? 0
        let maxScore = scoredCandidates.map { $0.score }.max() ?? 10
        let scoreRange = max(1, maxScore - minScore)
        let normalizedScore = Double(best.score - minScore) / Double(scoreRange)
        
        // Minimum confidence threshold
        let confidence = max(0.3, min(1.0, normalizedScore))
        
        // Extract merchant name
        let merchant = extractMerchant(fromHeaders: message.payload.headers) ?? extractMerchant(from: message)
        let normalizedCurrency = normalizeCurrency(best.candidate.currency, context: best.candidate.context)
        
        return ParsedReceipt(
            amountCents: best.candidate.amountCents,
            currency: normalizedCurrency,
            merchant: merchant,
            confidence: confidence
        )
    }
    
    // MARK: - Private
    
    private func scoreCandidate(_ candidate: AmountCandidate, context: String) -> Int {
        var score = 0
        let lowerContext = context.lowercased()
        
        // HIGH PRIORITY: "Total" keyword (most reliable indicator)
        if let totalRange = lowerContext.range(of: "total") {
            // Calculate distance from "total" keyword to amount position within context
            let totalIndex = lowerContext.distance(from: lowerContext.startIndex, to: totalRange.lowerBound)
            // The amount is somewhere in the context, find its relative position
            // Since context is extracted around the match, the amount should be near the center
            let contextMidpoint = lowerContext.count / 2
            let distance = abs(Int(totalIndex) - contextMidpoint)
            
            // Closer to "total" = higher score
            if distance < 20 {
                score += 10 // Very close to "Total"
            } else if distance < 50 {
                score += 7  // Close to "Total"
            } else if distance < 100 {
                score += 4  // Somewhat close
            }
        }
        
        // HIGH PRIORITY: Explicit charge/payment keywords
        if lowerContext.contains("charged") || lowerContext.contains("charged to") || lowerContext.contains("paid") || lowerContext.contains("amount due") {
            score += 6
        }
        
        // MEDIUM PRIORITY: Order/grand total
        if lowerContext.contains("order total") || lowerContext.contains("grand total") {
            score += 5
        }
        
        // MEDIUM PRIORITY: General amount keywords
        if lowerContext.contains("amount") {
            score += 3
        }
        
        // LOW PRIORITY: Subtotal (may not be the final amount)
        if lowerContext.contains("subtotal") {
            score += 3
        }
        
        // NEGATIVE SIGNALS: These suggest the amount is NOT the total
        // Tax, tip, fee, shipping are usually line items, not totals
        if lowerContext.contains("tax") || lowerContext.contains("tip") || 
           lowerContext.contains("fee") || lowerContext.contains("shipping") ||
           lowerContext.contains("insurance") || lowerContext.contains("hst") {
            score -= 3
        }
        
        // NEGATIVE SIGNALS: Discounts/savings (these are reductions, not totals)
        if lowerContext.contains("save") || lowerContext.contains("discount") || 
           lowerContext.contains("off") || lowerContext.contains("coupon") {
            score -= 4
        }
        
        // BONUS: Check if "Total" appears before the amount in the context
        // This is a strong signal that this is the total amount
        if let totalRange = lowerContext.range(of: "total") {
            let totalEndIndex = lowerContext.distance(from: lowerContext.startIndex, to: totalRange.upperBound)
            let contextMidpoint = lowerContext.count / 2
            // If amount (at midpoint) comes after "total", it's likely the total amount
            if contextMidpoint > totalEndIndex {
                score += 5 // Strong signal: "Total" followed by amount
            }
        }
        
        return score
    }
    
    /// Extracts a merchant from email headers by matching known sender domains.
    /// - Parameter headers: Gmail message headers.
    /// - Returns: Canonical merchant name when recognized.
    func extractMerchant(fromHeaders headers: [GmailHeader]) -> String? {
        let fromValue = headers.first(where: { $0.name.caseInsensitiveCompare("From") == .orderedSame })?.value ?? ""
        guard let senderDomain = domain(from: fromValue) else { return nil }

        if let exact = merchantDomains[senderDomain] {
            return exact
        }

        for (domain, canonical) in merchantDomains where senderDomain.hasSuffix(domain) {
            return canonical
        }
        return nil
    }

    private func extractMerchant(from message: GmailMessage) -> String {
        // Try to extract from "From" header
        let from = message.from
        
        // Common patterns: "Merchant Name <email@example.com>" or just "email@example.com"
        if let emailRange = from.range(of: "<") {
            let beforeEmail = String(from[..<emailRange.lowerBound]).trimmingCharacters(in: .whitespaces)
            if !beforeEmail.isEmpty {
                return beforeEmail
            }
        }
        
        // Extract domain from email
        if let emailRange = from.range(of: "@") {
            let afterAt = String(from[emailRange.upperBound...])
            if let domainEnd = afterAt.firstIndex(of: ">") {
                let domain = String(afterAt[..<domainEnd])
                return domain.components(separatedBy: ".").first?.capitalized ?? domain
            } else if let domainEnd = afterAt.firstIndex(of: " ") {
                let domain = String(afterAt[..<domainEnd])
                return domain.components(separatedBy: ".").first?.capitalized ?? domain
            } else {
                let domain = afterAt.components(separatedBy: ".").first ?? afterAt
                return domain.capitalized
            }
        }
        
        // Fallback to subject
        let subject = message.subject
        if !subject.isEmpty {
            return subject
        }
        
        return "Unknown"
    }

    private func normalizeCurrency(_ currency: String, context: String) -> String {
        let lowerContext = context.lowercased()
        if lowerContext.contains("ca$") || lowerContext.contains("c$") || lowerContext.contains("cad") {
            return "CAD"
        }
        if lowerContext.contains("usd") || lowerContext.contains("us$") {
            return "USD"
        }
        if currency == "USD" || currency == "CAD" {
            return currency
        }
        return "USD"
    }

    private func decodeHTMLEntities(in text: String) -> String {
        text
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&nbsp;", with: " ")
            .replacingOccurrences(of: "&#36;", with: "$")
    }

    private func domain(from fromHeader: String) -> String? {
        guard let atIndex = fromHeader.lastIndex(of: "@") else { return nil }
        let afterAt = fromHeader[fromHeader.index(after: atIndex)...]
        let domainChars = afterAt.prefix { character in
            character.isLetter || character.isNumber || character == "." || character == "-"
        }
        guard !domainChars.isEmpty else { return nil }
        return String(domainChars).lowercased()
    }
}

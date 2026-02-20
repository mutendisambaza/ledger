//
//  AmountPatterns.swift
//  ledger
//
//  Created for Ledger Phase 2
//

import Foundation

struct AmountPatterns {
    // Pattern: $X.XX or $X,XXX.XX (US format)
    static let dollarAmount = #"\$(\d{1,3}(?:,\d{3})*(?:\.\d{2})?)"#
    
    // Pattern: CA$X,XX or USD$X.XX (Currency code prefix with amount)
    // Handles both US (period) and European (comma) decimal separators
    static let currencyCodePrefix = #"(CA\$|USD\$|EUR\$|GBP\$|CAD\$)\s*(\d{1,3}(?:[.,]\d{3})*[.,]\d{2})"#
    
    // Pattern: X.XX USD or X,XX CAD (Currency suffix)
    static let currencySuffix = #"(\d{1,3}(?:[.,]\d{3})*[.,]\d{2})\s*(USD|CAD|EUR|GBP|CA\$|USD\$)"#
    
    // Pattern: USD X.XX or CAD X,XX (Currency prefix)
    static let currencyPrefix = #"(USD|CAD|EUR|GBP)\s*(\d{1,3}(?:[.,]\d{3})*[.,]\d{2})"#
    
    // Pattern: Total: $X.XX or Total CA$X,XX (Labeled amounts - HIGH PRIORITY)
    static let labeledAmount = #"(?:Total|Grand Total|Order Total|Amount Due|Amount Charged|Paid|Charged)[\s:]*\s*(?:CA\$|USD\$|EUR\$|GBP\$|CAD\$|\$)?\s*(\d{1,3}(?:[.,]\d{3})*[.,]\d{2})"#
    
    // Pattern: Charged $X.XX
    static let chargedAmount = #"charged\s*(?:CA\$|USD\$|\$)?\s*(\d{1,3}(?:[.,]\d{3})*[.,]\d{2})"#
    
    static func extractAmounts(from text: String) -> [AmountCandidate] {
        var candidates: [AmountCandidate] = []
        
        // Try all patterns (ordered by priority)
        // Higher priority patterns (like labeledAmount) should be checked first
        let patterns: [(String, Int, String)] = [
            (labeledAmount, 1, "CAD"),      // Highest priority - explicitly labeled
            (chargedAmount, 1, "CAD"),       // High priority - charged amounts
            (currencyCodePrefix, 2, "AUTO"), // Auto-detect currency from code
            (currencySuffix, 1, "AUTO"),     // Auto-detect currency from suffix
            (currencyPrefix, 2, "AUTO"),    // Auto-detect currency from prefix
            (dollarAmount, 1, "CAD")         // Fallback - assume CAD
        ]
        
        for (pattern, groupIndex, defaultCurrency) in patterns {
            do {
                let regex = try NSRegularExpression(pattern: pattern, options: [.caseInsensitive])
                let range = NSRange(location: 0, length: text.utf16.count)
                let matches = regex.matches(in: text, options: [], range: range)
                
                for match in matches {
                    guard match.numberOfRanges > groupIndex,
                          let amountRange = Range(match.range(at: groupIndex), in: text) else {
                        continue
                    }
                    
                    var amountString = String(text[amountRange])
                    var currency = defaultCurrency
                    
                    // Extract currency from pattern if available
                    if defaultCurrency == "AUTO" {
                        // Try to get currency from full match
                        if let fullRange = Range(match.range, in: text) {
                            let fullMatch = String(text[fullRange])
                            if fullMatch.contains("CA$") || fullMatch.contains("CAD") {
                                currency = "CAD"
                            } else if fullMatch.contains("USD$") || fullMatch.contains("USD") {
                                currency = "USD"
                            } else if fullMatch.contains("EUR$") || fullMatch.contains("EUR") {
                                currency = "EUR"
                            } else if fullMatch.contains("GBP$") || fullMatch.contains("GBP") {
                                currency = "GBP"
                            } else {
                                // Default to CAD if no currency code found
                                currency = "CAD"
                            }
                        }
                    }
                    
                    // Handle European decimal format (comma as decimal separator)
                    // e.g., "15,35" -> "15.35"
                    let isEuropeanFormat = amountString.contains(",") && !amountString.contains(".")
                    if isEuropeanFormat {
                        // Check if comma is decimal separator (not thousands separator)
                        // If format is like "15,35" (2 digits after comma), it's European
                        if let commaIndex = amountString.lastIndex(of: ",") {
                            let afterComma = String(amountString[amountString.index(after: commaIndex)...])
                            if afterComma.count == 2 && afterComma.allSatisfy({ $0.isNumber }) {
                                // European format: replace comma with period
                                amountString = amountString.replacingOccurrences(of: ",", with: ".")
                            } else {
                                // Thousands separator: remove commas
                                amountString = amountString.replacingOccurrences(of: ",", with: "")
                            }
                        }
                    } else {
                        // US format: remove thousands separators (commas)
                        amountString = amountString.replacingOccurrences(of: ",", with: "")
                    }
                    
                    guard let amount = Double(amountString) else {
                        continue
                    }
                    
                    let amountCents = Int(amount * 100)
                    
                    // Find context around the match (wider context for better scoring)
                    let matchRange = match.range
                    let contextStart = max(0, matchRange.location - 100)
                    let contextEnd = min(text.utf16.count, matchRange.location + matchRange.length + 100)
                    let contextRange = NSRange(location: contextStart, length: contextEnd - contextStart)
                    
                    if let context = Range(contextRange, in: text) {
                        let contextString = String(text[context])
                        let range = NSRange(location: matchRange.location, length: matchRange.length)
                        candidates.append(AmountCandidate(
                            range: range,
                            amountCents: amountCents,
                            currency: currency,
                            context: contextString
                        ))
                    }
                }
            } catch {
                continue
            }
        }
        
        return candidates
    }
}

struct AmountCandidate {
    let range: NSRange
    let amountCents: Int
    let currency: String
    let context: String // The surrounding text for scoring
}


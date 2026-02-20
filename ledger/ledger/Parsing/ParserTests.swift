//
//  ParserTests.swift
//  ledger
//
//  Created for Ledger Phase 2 - Test Cases
//
//  This file contains test cases for manual verification
//

import Foundation

struct ParserTestCases {
    static let testCases: [(input: String, expected: String)] = [
        ("Your order total is $29.99", "$29.99"),
        ("Amount charged: $150.00 USD", "$150.00"),
        ("Total: $12.34 (includes $1.00 tax)", "$12.34"),
        ("You saved $5.00! Total: $24.99", "$24.99")
    ]
    
    static func runTests() {
        let parser = ReceiptParser()
        
        for (index, testCase) in testCases.enumerated() {
            // Create a mock Gmail message
            let mockMessage = createMockMessage(body: testCase.input)
            
            if let parsed = parser.parse(message: mockMessage) {
                let formatted = String(format: "$%.2f", Double(parsed.amountCents) / 100.0)
                print("Test \(index + 1): \(testCase.input)")
                print("  Expected: \(testCase.expected)")
                print("  Got: \(formatted)")
                print("  Confidence: \(parsed.confidence)")
                print("  Match: \(formatted == testCase.expected ? "✓" : "✗")")
            } else {
                print("Test \(index + 1): \(testCase.input)")
                print("  Expected: \(testCase.expected)")
                print("  Got: nil (parse failed)")
                print("  Match: ✗")
            }
            print()
        }
    }
    
    private static func createMockMessage(body: String) -> GmailMessage {
        let payload = GmailPayload(
            headers: [
                GmailHeader(name: "From", value: "merchant@example.com"),
                GmailHeader(name: "Subject", value: "Receipt")
            ],
            body: GmailBody(data: nil, size: 0),
            parts: nil
        )
        
        return GmailMessage(
            id: "test-\(UUID().uuidString)",
            snippet: body,
            payload: payload,
            internalDate: String(Int(Date().timeIntervalSince1970 * 1000))
        )
    }
}


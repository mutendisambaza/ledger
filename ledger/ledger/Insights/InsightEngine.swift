//
//  InsightEngine.swift
//  ledger
//
//  Created for Ledger Phase 3
//

import Foundation

final class InsightEngine {
    
    func generateInsight(transactions: [Transaction], todayTotalCents: Int) -> Insight? {
        // Priority order - return first match
        
        // 1. ACCUMULATION: >5 transactions under $15 today
        let smallPurchases = transactions.filter { $0.amountCents < 1500 }
        if smallPurchases.count >= 5 {
            return Insight(
                type: .accumulation,
                message: "Small purchases are adding up."
            )
        }
        
        // 2. VELOCITY: >3 transactions in last hour
        let oneHourAgo = Date().addingTimeInterval(-3600)
        let recentCount = transactions.filter { $0.timestamp > oneHourAgo }.count
        if recentCount >= 3 {
            return Insight(
                type: .velocity,
                message: "Ledger noticed \(recentCount) transactions this hour."
            )
        }
        
        // 3. UNUSUAL: any transaction > $100
        if let largest = transactions.max(by: { $0.amountCents < $1.amountCents }),
           largest.amountCents > 10000 {
            return Insight(
                type: .unusual,
                message: "This is larger than your typical purchase."
            )
        }
        
        // No insight
        return nil
    }
}


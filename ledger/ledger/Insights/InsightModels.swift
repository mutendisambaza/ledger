//
//  InsightModels.swift
//  ledger
//
//  Created for Ledger Phase 3
//

import Foundation

enum InsightType {
    case accumulation  // many small purchases
    case velocity      // multiple purchases in short time
    case unusual       // larger than average
    case aboveAverage  // today > typical day
}

struct Insight: Identifiable {
    let id = UUID()
    let type: InsightType
    let message: String
}


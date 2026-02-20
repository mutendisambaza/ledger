//
//  WidgetViews.swift
//  LedgerWidget
//
//  Created for Ledger Phase 1
//

import WidgetKit
import SwiftUI

struct LedgerRectangularView: View {
    let total: String
    let isStale: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Ledger")
                .font(.caption)
                .foregroundColor(.secondary)
            
            if isStale {
                Text("--")
                    .font(.system(size: 20, weight: .bold, design: .monospaced))
                    .foregroundColor(.primary)
            } else {
                Text(total)
                    .font(.system(size: 20, weight: .bold, design: .monospaced))
                    .foregroundColor(.primary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct LedgerInlineView: View {
    let total: String
    let isStale: Bool
    
    var body: some View {
        HStack(spacing: 4) {
            Text("Ledger:")
                .font(.system(size: 14, weight: .medium))
            if isStale {
                Text("--")
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
            } else {
                Text(total)
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
            }
        }
    }
}

// Home Screen widget view (for preview/development purposes)
struct LedgerHomeScreenView: View {
    let total: String
    let isStale: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Ledger")
                .font(.headline)
                .foregroundColor(.primary)
            
            if isStale {
                Text("--")
                    .font(.system(size: 32, weight: .bold, design: .monospaced))
                    .foregroundColor(.primary)
            } else {
                Text(total)
                    .font(.system(size: 32, weight: .bold, design: .monospaced))
                    .foregroundColor(.primary)
            }
            
            Text("today so far")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding()
    }
}


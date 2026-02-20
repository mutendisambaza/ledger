//
//  EmptyStateView.swift
//  ledger
//
//  Created for Ledger Phase 3
//

import SwiftUI

struct EmptyStateView: View {
    @State private var appeared = false
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "eye")
                .font(.system(size: 32, weight: .light))
                .foregroundColor(Color(hex: "A1A1AA").opacity(0.5))
                .padding(.bottom, 8)
            
            Text("No spending detected today")
                .font(.body)
                .foregroundColor(Color(hex: "A1A1AA"))
            
            Text("Ledger is watching")
                .font(.caption)
                .foregroundColor(Color(hex: "A1A1AA").opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 48)
        .opacity(appeared ? 1 : 0)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
                appeared = true
            }
        }
    }
}


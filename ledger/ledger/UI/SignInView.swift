//
//  SignInView.swift
//  ledger
//
//  Created for Ledger Phase 3
//

import SwiftUI

struct SignInView: View {
    @ObservedObject var authManager: GoogleAuthManager
    @State private var appeared = false
    @State private var isLoading = false
    @State private var logoScale: CGFloat = 0.8
    
    var body: some View {
        ZStack {
            // Background
            Color(hex: "0B0B0C").ignoresSafeArea()
            
            // Subtle gradient overlay
            RadialGradient(
                colors: [
                    Color(hex: "3B82F6").opacity(0.1),
                    Color.clear
                ],
                center: .top,
                startRadius: 0,
                endRadius: 400
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // Logo area
                VStack(spacing: 16) {
                    // App icon placeholder
                    RoundedRectangle(cornerRadius: 24)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hex: "3B82F6"),
                                    Color(hex: "3B82F6").opacity(0.7)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                        .overlay(
                            Text("L")
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        )
                        .scaleEffect(logoScale)
                    
                    Text("Ledger")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Tracks money so you don't have to")
                        .font(.subheadline)
                        .foregroundColor(Color(hex: "A1A1AA"))
                }
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)
                
                Spacer()
                Spacer()
                
                // Sign in button
                Button(action: {
                    isLoading = true
                    Task {
                        do {
                            try await authManager.signIn()
                        } catch {
                            print("Sign in error: \(error)")
                        }
                        isLoading = false
                    }
                }) {
                    HStack(spacing: 12) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: Color(hex: "0B0B0C")))
                        } else {
                            Image(systemName: "envelope.fill")
                        }
                        Text(isLoading ? "Connecting..." : "Continue with Gmail")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(Color.white)
                    .foregroundColor(Color(hex: "0B0B0C"))
                    .cornerRadius(14)
                }
                .disabled(isLoading)
                .padding(.horizontal, 24)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 30)
                
                // Footer
                Text("Ledger reads your receipts to show daily spending")
                    .font(.caption)
                    .foregroundColor(Color(hex: "A1A1AA").opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.top, 16)
                    .padding(.horizontal, 40)
                    .opacity(appeared ? 1 : 0)
                
                Spacer()
                    .frame(height: 50)
            }
        }
        .onAppear {
            withAnimation(.ledgerSpring.delay(0.2)) {
                appeared = true
            }
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                logoScale = 1.0
            }
        }
    }
}


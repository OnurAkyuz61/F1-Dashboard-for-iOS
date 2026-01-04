//
//  AboutView.swift
//  F1-Dashboard
//
//  Created by Onur Akyüz on 4.01.2026.
//

import SwiftUI

struct AboutView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.darkBackground.ignoresSafeArea()
            
            VStack(spacing: 32) {
                Spacer()
                
                // F1 Logo
                Image("f1-logo")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 80)
                    .padding(.bottom, 8)
                
                // App Title
                Text("Unofficial F1 Companion App")
                    .font(.system(.title2, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                // Data Source
                VStack(spacing: 12) {
                    Text("Data provided by Ergast/Jolpi API.")
                        .font(.system(.body, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                    
                    Text("F1 marks are trademarks of Formula One Licensing BV.")
                        .font(.system(.caption, design: .rounded))
                        .foregroundColor(.white.opacity(0.5))
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 40)
                
                // Credits
                VStack(spacing: 8) {
                    Text("Designed & Developed by")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(.white.opacity(0.6))
                    
                    Text("Onur Akyuz")
                        .font(.system(.title3, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(.f1Red)
                }
                .padding(.top, 16)
                
                Spacer()
                
                // Dismiss Button
                Button(action: { dismiss() }) {
                    Text("Close")
                        .font(.system(.headline, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 12)
                        .background(Color.f1Red)
                        .cornerRadius(12)
                }
                .padding(.bottom, 40)
            }
            .padding(.horizontal, 32)
        }
    }
}

#Preview {
    AboutView()
}


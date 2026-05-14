//
//  AboutView.swift
//  F1-Dashboard
//
//  Created by Onur Akyüz on 4.01.2026.
//

import SwiftUI

struct AboutView: View {
    /// When `true` (e.g. sheet from Home), show a Close control.
    var showDismiss: Bool = false
    
    @Environment(\.dismiss) private var dismiss
    
    private let webDashboardURL = URL(string: "https://f1-dashboard-nine-omega.vercel.app/")!
    private let personalSiteURL = URL(string: "https://onurakyuz.com")!
    
    var body: some View {
        ZStack {
            Color.darkBackground.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 28) {
                    Image("f1-logo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 72)
                        .padding(.top, 8)
                    
                    VStack(spacing: 6) {
                        Text("F1 DASHBOARD")
                            .font(.system(size: 26, weight: .heavy, design: .default))
                            .foregroundColor(.white)
                            .f1DisplayStyle(tracking: 2)
                        
                        Text("Unofficial companion for iOS")
                            .font(.system(size: 15, weight: .medium, design: .default))
                            .foregroundColor(.white.opacity(0.55))
                    }
                    
                    Text("This app shows live season schedules, standings, and race winners using the same public JSON API as the web dashboard — no private backend.")
                        .font(.system(size: 15, weight: .regular, design: .default))
                        .foregroundColor(.white.opacity(0.72))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)
                    
                    VStack(spacing: 14) {
                        linkRow(
                            title: "Web dashboard",
                            subtitle: "f1-dashboard-nine-omega.vercel.app",
                            systemImage: "safari.fill",
                            url: webDashboardURL
                        )
                        
                        linkRow(
                            title: "onurakyuz.com",
                            subtitle: "Personal site",
                            systemImage: "link",
                            url: personalSiteURL
                        )
                    }
                    .padding(.top, 4)
                    
                    VStack(spacing: 10) {
                        Text("Designed & built by")
                            .font(.system(size: 13, weight: .medium, design: .default))
                            .foregroundColor(.white.opacity(0.5))
                        
                        Text("Onur AKyüz")
                            .font(.system(size: 22, weight: .heavy, design: .default))
                            .foregroundColor(.f1Red)
                    }
                    .padding(.top, 8)
                    
                    AttributionFooter()
                        .padding(.top, 12)
                    
                    if showDismiss {
                        Button(action: { dismiss() }) {
                            Text("Close")
                                .font(.system(size: 17, weight: .semibold, design: .default))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.f1Red)
                                .cornerRadius(12)
                        }
                        .padding(.top, 8)
                    }
                }
                .padding(.horizontal, 28)
                .padding(.bottom, 32)
            }
        }
    }
    
    @ViewBuilder
    private func linkRow(title: String, subtitle: String, systemImage: String, url: URL) -> some View {
        Link(destination: url) {
            HStack(spacing: 14) {
                Image(systemName: systemImage)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(.f1Red)
                    .frame(width: 36)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold, design: .default))
                        .foregroundColor(.white)
                    Text(subtitle)
                        .font(.system(size: 12, weight: .medium, design: .default))
                        .foregroundColor(.white.opacity(0.45))
                }
                
                Spacer()
                
                Image(systemName: "arrow.up.right")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white.opacity(0.35))
            }
            .padding(16)
            .background(Color.white.opacity(0.06))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.white.opacity(0.12), lineWidth: 1)
            )
            .cornerRadius(14)
        }
    }
}

#Preview("Sheet") {
    AboutView(showDismiss: true)
}

#Preview("Tab") {
    AboutView(showDismiss: false)
}

//
//  TeamsView.swift
//  F1-Dashboard
//
//  Created by Onur Akyüz on 4.01.2026.
//

import SwiftUI

struct TeamsView: View {
    @State private var constructorStandings: [ConstructorStanding] = []
    @State private var isLoading = true
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        ZStack {
            Color.darkBackground.ignoresSafeArea()
            
            if isLoading {
                VStack {
                    ProgressView()
                        .tint(.f1Red)
                    Text("Loading Teams...")
                        .font(AppFont.orbitron(17, weight: .semibold))
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.top, 16)
                }
            } else if constructorStandings.isEmpty {
                VStack {
                    Image(systemName: "person.3.fill")
                        .font(.system(.largeTitle))
                        .foregroundColor(.f1Red.opacity(0.5))
                    Text("No teams available")
                        .font(AppFont.orbitron(17, weight: .semibold))
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.top, 16)
                }
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(constructorStandings) { standing in
                            PremiumTeamCard(standing: standing)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                    .padding(.bottom, 90)
                }
            }
        }
        .task {
            await loadData()
        }
    }
    
    private func loadData() async {
        isLoading = true
        let result = await F1DataService.shared.fetchConstructorStandings()
        
        await MainActor.run {
            self.constructorStandings = result.standings
            self.isLoading = false
        }
    }
}

// MARK: - Premium Team Card
struct PremiumTeamCard: View {
    let standing: ConstructorStanding
    
    var teamColor: Color {
        teamColorFor(constructorId: standing.constructor.constructorId)
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            // Team Name - Large
            Text(standing.constructor.name)
                .font(AppFont.orbitron(20, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(minHeight: 60)
            
            Spacer()
            
            // Position & Points
            VStack(spacing: 8) {
                HStack(spacing: 4) {
                    Text("Position:")
                        .font(AppFont.orbitron(12, weight: .regular))
                        .foregroundColor(.white.opacity(0.6))
                    Text("#\(standing.position)")
                        .font(AppFont.orbitron(17, weight: .bold))
                        .foregroundColor(.white)
                }
                
                HStack(spacing: 4) {
                    Text("Points:")
                        .font(AppFont.orbitron(12, weight: .regular))
                        .foregroundColor(.white.opacity(0.6))
                    Text(standing.points)
                        .font(AppFont.orbitron(17, weight: .bold))
                        .foregroundColor(.f1Red)
                }
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .frame(height: 200)
        .glassCard()
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(teamColor.opacity(0.6), lineWidth: 2)
        )
    }
    
    private func teamColorFor(constructorId: String) -> Color {
        switch constructorId.lowercased() {
        case "red_bull", "red_bull_racing":
            return Color(hex: "1E41FF") // Blue
        case "ferrari":
            return Color(hex: "DC143C") // Red
        case "mercedes":
            return Color(hex: "00D2BE") // Teal
        case "mclaren":
            return Color(hex: "FF8700") // Orange
        case "aston_martin", "aston_martin_aramco":
            return Color(hex: "00665E") // Green
        case "alpine":
            return Color(hex: "0090FF") // Blue
        case "williams":
            return Color(hex: "005AFF") // Blue
        case "alphatauri", "rb":
            return Color(hex: "2B4562") // Dark Blue
        case "haas":
            return Color(hex: "FFFFFF") // White
        case "sauber", "alfa_romeo", "stake":
            return Color(hex: "900000") // Dark Red
        default:
            return .f1Red
        }
    }
}

#Preview {
    TeamsView()
}

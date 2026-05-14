//
//  StandingsView.swift
//  F1-Dashboard
//
//  Created by Onur Akyüz on 4.01.2026.
//

import SwiftUI

struct StandingsView: View {
    @State private var selectedTab: StandingsTab = .drivers
    @State private var driverStandings: [DriverStanding] = []
    @State private var constructorStandings: [ConstructorStanding] = []
    @State private var driverSeason: Int = 2026
    @State private var constructorSeason: Int = 2026
    @State private var isLoading = true
    
    enum StandingsTab: String, CaseIterable {
        case drivers = "Drivers"
        case constructors = "Constructors"
    }
    
    var currentSeason: Int {
        selectedTab == .drivers ? driverSeason : constructorSeason
    }
    
    var seasonDisplay: String {
        "\(currentSeason) Season"
    }
    
    var body: some View {
        ZStack {
            Color.darkBackground.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header with Season Display
                VStack(spacing: 12) {
                    // Picker
                    Picker("Standings Type", selection: $selectedTab) {
                        ForEach(StandingsTab.allCases, id: \.self) { tab in
                            Text(tab.rawValue).tag(tab)
                        }
                    }
                    .pickerStyle(.segmented)
                    .tint(.f1Red)
                    
                    // Season Badge
                    Text(seasonDisplay)
                        .font(AppFont.orbitron(12, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(8)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 20)
                
                if isLoading {
                    Spacer()
                    ProgressView()
                        .tint(.f1Red)
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            if selectedTab == .drivers {
                                ForEach(driverStandings) { standing in
                                    PremiumStandingRow(standing: standing)
                                }
                            } else {
                                ForEach(constructorStandings) { standing in
                                    PremiumConstructorRow(standing: standing)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 90)
                    }
                }
            }
        }
        .task {
            await loadData()
        }
    }
    
    private func loadData() async {
        isLoading = true
        
        async let driversTask = F1DataService.shared.fetchStandings()
        async let constructorsTask = F1DataService.shared.fetchConstructorStandings()
        
        let (driversResult, constructorsResult) = await (driversTask, constructorsTask)
        
        await MainActor.run {
            self.driverStandings = driversResult.standings
            self.driverSeason = driversResult.season
            self.constructorStandings = constructorsResult.standings
            self.constructorSeason = constructorsResult.season
            self.isLoading = false
        }
    }
}

// MARK: - Premium Standing Row
struct PremiumStandingRow: View {
    let standing: DriverStanding
    
    var rankColor: Color {
        switch standing.positionInt {
        case 1: return .yellow
        case 2: return Color(white: 0.75) // Silver
        case 3: return Color(red: 0.8, green: 0.5, blue: 0.2) // Bronze
        default: return .white
        }
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Rank - Big, Bold, Monospaced
            Text(standing.position)
                .font(AppFont.orbitron(32, weight: .bold))
                .foregroundColor(rankColor)
                .frame(width: 50, alignment: .leading)
            
            // Driver Info
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 4) {
                    Text(standing.driver.givenName)
                        .font(AppFont.orbitron(17, weight: .regular))
                        .foregroundColor(.white.opacity(0.6))
                    
                    Text(standing.driver.familyName)
                        .font(AppFont.orbitron(17, weight: .bold))
                        .foregroundColor(.white)
                }
                
                // Team Name
                if let constructor = standing.constructors.first {
                    Text(constructor.name)
                        .font(AppFont.orbitron(12, weight: .regular))
                        .foregroundColor(.white.opacity(0.5))
                }
            }
            
            Spacer()
            
            // Points - Accent Red
            Text(standing.points)
                .font(AppFont.orbitron(22, weight: .bold))
                .foregroundColor(.f1Red)
        }
        .padding(18)
        .glassCard(cornerRadius: 12)
    }
}

// MARK: - Premium Constructor Row
struct PremiumConstructorRow: View {
    let standing: ConstructorStanding
    
    var body: some View {
        HStack(spacing: 16) {
            // Rank
            Text(standing.position)
                .font(AppFont.orbitron(32, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 50, alignment: .leading)
            
            // Constructor Info
            VStack(alignment: .leading, spacing: 6) {
                Text(standing.constructor.name)
                    .font(AppFont.orbitron(17, weight: .bold))
                    .foregroundColor(.white)
                
                Text(standing.constructor.nationality)
                    .font(AppFont.orbitron(12, weight: .regular))
                    .foregroundColor(.white.opacity(0.5))
            }
            
            Spacer()
            
            // Points
            Text(standing.points)
                .font(AppFont.orbitron(22, weight: .bold))
                .foregroundColor(.f1Red)
        }
        .padding(18)
        .glassCard(cornerRadius: 12)
    }
}

#Preview {
    StandingsView()
}

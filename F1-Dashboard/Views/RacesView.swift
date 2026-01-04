//
//  RacesView.swift
//  F1-Dashboard
//
//  Created by Onur Akyüz on 4.01.2026.
//

import SwiftUI

struct RacesView: View {
    @State private var races: [Race] = []
    @State private var isLoading = true
    
    var body: some View {
        ZStack {
            Color.darkBackground.ignoresSafeArea()
            
            if isLoading {
                VStack {
                    ProgressView()
                        .tint(.f1Red)
                    Text("Loading Race Calendar...")
                        .font(.system(.headline, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.top, 16)
                }
            } else if races.isEmpty {
                VStack {
                    Image(systemName: "flag.checkered")
                        .font(.system(.largeTitle))
                        .foregroundColor(.f1Red.opacity(0.5))
                    Text("No races available")
                        .font(.system(.headline, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.top, 16)
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(races) { race in
                            PremiumRaceCard(race: race)
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
        let fetchedRaces = await F1DataService.shared.fetchSchedule()
        
        await MainActor.run {
            self.races = fetchedRaces.sorted { race1, race2 in
                guard let date1 = race1.raceDate, let date2 = race2.raceDate else { return false }
                return date1 < date2
            }
            self.isLoading = false
        }
    }
}

// MARK: - Premium Race Card
struct PremiumRaceCard: View {
    let race: Race
    
    var isUpcoming: Bool {
        guard let raceDate = race.raceDate else { return false }
        return raceDate > Date()
    }
    
    var isPast: Bool {
        guard let raceDate = race.raceDate else { return false }
        return raceDate < Date()
    }
    
    var formattedDate: String {
        guard let raceDate = race.raceDate else { return "TBD" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: raceDate)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Top Row: Round Badge & Status Badge
            HStack {
                // Round Badge
                Text("Round \(race.round)")
                    .font(.system(.caption, design: .monospaced))
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(12)
                
                Spacer()
                
                // Status Badge
                HStack(spacing: 6) {
                    Circle()
                        .fill(isUpcoming ? Color.f1Red : Color.green)
                        .frame(width: 8, height: 8)
                    
                    Text(isUpcoming ? "Upcoming" : isPast ? "Completed" : "Live")
                        .font(.system(.caption, design: .rounded))
                        .fontWeight(.semibold)
                        .foregroundColor(isUpcoming ? .f1Red : isPast ? .green : .f1Red)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background((isUpcoming ? Color.f1Red : Color.green).opacity(0.15))
                .cornerRadius(12)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 16)
            
            Divider()
                .background(Color.white.opacity(0.1))
                .padding(.horizontal, 20)
            
            // Middle: Race Name - Large Title
            VStack(spacing: 8) {
                Text(race.raceName)
                    .font(.system(.title2, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text(race.circuit.circuitName)
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            
            Divider()
                .background(Color.white.opacity(0.1))
                .padding(.horizontal, 20)
            
            // Bottom: Date & Time - Formatted Neatly
            HStack(spacing: 12) {
                Image(systemName: "calendar")
                    .font(.system(.caption))
                    .foregroundColor(.f1Red.opacity(0.7))
                
                Text(formattedDate)
                    .font(.system(.subheadline, design: .monospaced))
                    .foregroundColor(.white.opacity(0.8))
                
                Spacer()
                
                Image(systemName: "location.fill")
                    .font(.system(.caption))
                    .foregroundColor(.f1Red.opacity(0.7))
                
                Text("\(race.circuit.location.locality), \(race.circuit.location.country)")
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(.white.opacity(0.6))
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 20)
        }
        .glassCard()
        .opacity(isPast ? 0.65 : 1.0)
    }
}

#Preview {
    RacesView()
}

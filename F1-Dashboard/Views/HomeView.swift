//
//  HomeView.swift
//  F1-Dashboard
//
//  Created by Onur Akyüz on 4.01.2026.
//

import SwiftUI
import Combine

struct HomeView: View {
    @State private var nextRace: Race?
    @State private var standings: [DriverStanding] = []
    @State private var standingsSeason: Int = 2026
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var showAbout = false
    
    @State private var timeRemaining: TimeInterval = 0
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var seasonDisplay: String {
        "\(standingsSeason) Season"
    }
    
    var body: some View {
        ZStack {
            Color.darkBackground.ignoresSafeArea()
            
            if isLoading {
                // Loading State
                VStack(spacing: 16) {
                    ProgressView()
                        .tint(.f1Red)
                        .scaleEffect(1.5)
                    
                    Text("Fetching F1 Data...")
                        .font(.system(.headline, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = errorMessage {
                // Error State
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(.largeTitle))
                        .foregroundColor(.f1Red)
                    
                    Text("Error")
                        .font(.system(.title2, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(error)
                        .font(.system(.body, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        HomeHeader(showAbout: $showAbout)
                        
                        // Hero Card - Next Race Countdown (Always shown)
                        if let race = nextRace {
                            PremiumNextRaceCard(race: race, timeRemaining: timeRemaining)
                        } else {
                            // Skeleton/Placeholder while loading
                            PremiumNextRaceCardSkeleton()
                        }
                        
                        // Standings Preview
                        if !standings.isEmpty {
                            PremiumStandingsPreview(standings: Array(standings.prefix(3)), seasonDisplay: seasonDisplay)
                        }
                        
                        // Circuit Info (Always shown if race exists)
                        if let race = nextRace {
                            PremiumCircuitInfoCard(race: race)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 90)
                }
            }
        }
        .task {
            await loadData()
        }
        .onReceive(timer) { _ in
            updateCountdown()
        }
        .sheet(isPresented: $showAbout) {
            AboutView(showDismiss: true)
        }
    }
    
    private func loadData() async {
        isLoading = true
        errorMessage = nil
        
        async let nextRaceTask = F1DataService.shared.fetchNextRace()
        async let standingsTask = F1DataService.shared.fetchStandings()
        
        let (race, standingsResult) = await (nextRaceTask, standingsTask)
        
        await MainActor.run {
            // Service now guarantees a race (real or fallback), but handle nil just in case
            if let race = race {
                self.nextRace = race
            } else {
                // Last resort fallback (should never happen, but ensures Hero always shows)
                self.nextRace = F1DataService.shared.createFallbackRace()
            }
            
            self.standings = standingsResult.standings
            self.standingsSeason = standingsResult.season
            self.isLoading = false
            updateCountdown()
            
            // Only show error if standings are empty (race is guaranteed)
            if standingsResult.standings.isEmpty {
                self.errorMessage = "Unable to load standings data. Please check your connection."
            }
        }
    }
    
    private func updateCountdown() {
        guard let race = nextRace,
              let raceDate = race.raceDate else {
            timeRemaining = 0
            return
        }
        timeRemaining = max(0, raceDate.timeIntervalSinceNow)
    }
}

// MARK: - Home Header
struct HomeHeader: View {
    @Binding var showAbout: Bool
    
    var body: some View {
        HStack {
            Image("f1-logo")
                .resizable()
                .scaledToFit()
                .frame(height: 24)
            
            Spacer()
            
            Button(action: { showAbout = true }) {
                Image(systemName: "gearshape.fill")
                    .font(.system(.title3))
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding(.horizontal, 4)
    }
}

// MARK: - Premium Next Race Card Skeleton
struct PremiumNextRaceCardSkeleton: View {
    var body: some View {
        ZStack {
            // Red glow effect behind timer
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.f1Red.opacity(0.3), Color.f1Red.opacity(0.0)],
                        center: .center,
                        startRadius: 50,
                        endRadius: 150
                    )
                )
                .blur(radius: 30)
                .frame(width: 200, height: 200)
                .offset(y: 20)
            
            VStack(spacing: 20) {
                Text("NEXT RACE")
                    .font(.system(.title, design: .monospaced))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .tracking(2)
                
                VStack(spacing: 8) {
                    Text("Loading...")
                        .font(.system(.title2, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(.white.opacity(0.6))
                    
                    Text("Fetching race data")
                        .font(.system(.body, design: .rounded))
                        .foregroundColor(.white.opacity(0.5))
                }
                
                // Placeholder countdown
                HStack(spacing: 8) {
                    ForEach(0..<4) { _ in
                        VStack(spacing: 6) {
                            Text("--")
                                .font(.system(size: 42, weight: .bold, design: .monospaced))
                                .foregroundColor(.white.opacity(0.3))
                            
                            Text("---")
                                .font(.system(.caption, design: .monospaced))
                                .foregroundColor(.white.opacity(0.3))
                        }
                        .frame(minWidth: 60)
                    }
                }
                .padding(.vertical, 20)
            }
            .padding(28)
        }
        .glassCard()
        .shadow(color: .f1Red.opacity(0.4), radius: 25, x: 0, y: 15)
    }
}

// MARK: - Premium Next Race Card
struct PremiumNextRaceCard: View {
    let race: Race
    let timeRemaining: TimeInterval
    
    var body: some View {
        ZStack {
            // Red glow effect behind timer
            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color.f1Red.opacity(0.3), Color.f1Red.opacity(0.0)],
                        center: .center,
                        startRadius: 50,
                        endRadius: 150
                    )
                )
                .blur(radius: 30)
                .frame(width: 200, height: 200)
                .offset(y: 20)
            
            VStack(spacing: 20) {
                Text("NEXT RACE")
                    .font(.system(.title, design: .monospaced))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .tracking(2)
                
                VStack(spacing: 8) {
                    Text(race.raceName)
                        .font(.system(.title2, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(race.circuit.circuitName)
                        .font(.system(.body, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                // Premium Countdown Timer
                PremiumCountdownView(timeRemaining: timeRemaining)
                
                // Circuit details
                HStack(spacing: 24) {
                    CircuitDetailItem(icon: "stopwatch.fill", label: "Laps", value: "58")
                    CircuitDetailItem(icon: "ruler.fill", label: "Length", value: "5.278 km")
                }
                .padding(.top, 8)
            }
            .padding(28)
        }
        .glassCard()
        .shadow(color: .f1Red.opacity(0.4), radius: 25, x: 0, y: 15)
    }
}

struct CircuitDetailItem: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(.caption2))
                    .foregroundColor(.f1Red)
                Text(label)
                    .font(.system(.caption2, design: .rounded))
                    .foregroundColor(.white.opacity(0.6))
            }
            Text(value)
                .font(.system(.subheadline, design: .monospaced))
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
    }
}

// MARK: - Premium Countdown View
struct PremiumCountdownView: View {
    let timeRemaining: TimeInterval
    
    var days: Int { Int(timeRemaining) / 86400 }
    var hours: Int { (Int(timeRemaining) % 86400) / 3600 }
    var minutes: Int { (Int(timeRemaining) % 3600) / 60 }
    var seconds: Int { Int(timeRemaining) % 60 }
    
    var body: some View {
        HStack(spacing: 8) {
            PremiumTimeUnit(value: days, label: "DAYS")
            Text(":")
                .foregroundColor(.f1Red)
                .font(.system(size: 32, weight: .bold, design: .monospaced))
            PremiumTimeUnit(value: hours, label: "HRS")
            Text(":")
                .foregroundColor(.f1Red)
                .font(.system(size: 32, weight: .bold, design: .monospaced))
            PremiumTimeUnit(value: minutes, label: "MIN")
            Text(":")
                .foregroundColor(.f1Red)
                .font(.system(size: 32, weight: .bold, design: .monospaced))
            PremiumTimeUnit(value: seconds, label: "SEC")
        }
        .padding(.vertical, 20)
    }
}

struct PremiumTimeUnit: View {
    let value: Int
    let label: String
    
    var body: some View {
        VStack(spacing: 6) {
            Text(String(format: "%02d", value))
                .font(.system(size: 42, weight: .bold, design: .monospaced))
                .monospacedDigit()
                .foregroundColor(.f1Red)
                .shadow(color: .f1Red.opacity(0.8), radius: 15, x: 0, y: 0)
            
            Text(label)
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.white.opacity(0.6))
                .tracking(1)
        }
        .frame(minWidth: 60)
    }
}

// MARK: - Premium Standings Preview
struct PremiumStandingsPreview: View {
    let standings: [DriverStanding]
    let seasonDisplay: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Driver Standings")
                    .font(.system(.title2, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text(seasonDisplay)
                    .font(.system(.caption, design: .rounded))
                    .fontWeight(.medium)
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(8)
            }
            .padding(.horizontal, 4)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(standings) { standing in
                        PremiumDriverCard(standing: standing)
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }
}

struct PremiumDriverCard: View {
    let standing: DriverStanding
    
    var body: some View {
        VStack(spacing: 14) {
            // Rank Badge
            ZStack {
                Circle()
                    .fill(standing.positionInt == 1 ? 
                          LinearGradient(colors: [Color.yellow.opacity(0.4), Color.yellow.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing) :
                          LinearGradient(colors: [Color.white.opacity(0.15), Color.white.opacity(0.05)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 56, height: 56)
                
                Text("#\(standing.position)")
                    .font(.system(.title2, design: .monospaced))
                    .fontWeight(.bold)
                    .foregroundColor(standing.positionInt == 1 ? .yellow : .white)
            }
            
            // Driver Name
            Text(standing.driver.fullName)
                .font(.system(.headline, design: .rounded))
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(height: 40)
            
            // Points
            Text("\(standing.points) PTS")
                .font(.system(.title3, design: .monospaced))
                .foregroundColor(.f1Red)
                .fontWeight(.bold)
        }
        .padding(18)
        .frame(width: 150)
        .glassCard()
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    standing.positionInt == 1 ? 
                    LinearGradient(colors: [Color.yellow.opacity(0.8), Color.yellow.opacity(0.4)], startPoint: .topLeading, endPoint: .bottomTrailing) :
                    LinearGradient(colors: [Color.clear], startPoint: .topLeading, endPoint: .bottomTrailing),
                    lineWidth: standing.positionInt == 1 ? 2 : 0
                )
        )
        .shadow(color: standing.positionInt == 1 ? Color.yellow.opacity(0.3) : Color.clear, radius: 15, x: 0, y: 5)
    }
}

// MARK: - Premium Circuit Info Card
struct PremiumCircuitInfoCard: View {
    let race: Race
    
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack {
                Image(systemName: "map.fill")
                    .foregroundColor(.f1Red)
                    .font(.title2)
                
                Text(race.circuit.circuitName)
                    .font(.system(.title3, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            Divider()
                .background(Color.white.opacity(0.2))
            
            HStack(spacing: 24) {
                CircuitInfoRow(
                    icon: "stopwatch.fill",
                    label: "Laps",
                    value: "58"
                )
                
                CircuitInfoRow(
                    icon: "ruler.fill",
                    label: "Length",
                    value: "5.278 km"
                )
            }
            
            HStack {
                Image(systemName: "location.fill")
                    .foregroundColor(.f1Red.opacity(0.7))
                    .font(.caption)
                
                Text("\(race.circuit.location.locality), \(race.circuit.location.country)")
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding(24)
        .glassCard()
    }
}

struct CircuitInfoRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .foregroundColor(.f1Red)
                    .font(.caption)
                
                Text(label)
                    .font(.system(.caption, design: .rounded))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Text(value)
                .font(.system(.headline, design: .monospaced))
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
    }
}

#Preview {
    HomeView()
}

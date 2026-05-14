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
    
    @State private var timeRemaining: TimeInterval = 0
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var seasonDisplay: String {
        "\(standingsSeason) Season"
    }
    
    var body: some View {
        ZStack {
            Color.darkBackground.ignoresSafeArea()
            
            if isLoading {
                VStack(spacing: 16) {
                    ProgressView()
                        .tint(.f1Red)
                        .scaleEffect(1.5)
                    
                    Text("Fetching F1 Data...")
                        .font(AppFont.orbitron(17, weight: .semibold))
                        .foregroundColor(.white.opacity(0.7))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = errorMessage {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(.largeTitle))
                        .foregroundColor(.f1Red)
                    
                    Text("Error")
                        .font(AppFont.orbitron(22, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(error)
                        .font(AppFont.orbitron(15, weight: .regular))
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(spacing: 24) {
                        HomeHeader()
                        
                        if let race = nextRace {
                            PremiumNextRaceCard(race: race, timeRemaining: timeRemaining)
                        } else {
                            PremiumNextRaceCardSkeleton()
                        }
                        
                        if !standings.isEmpty {
                            PremiumStandingsPreview(standings: Array(standings.prefix(3)), seasonDisplay: seasonDisplay)
                        }
                        
                        if let race = nextRace {
                            PremiumCircuitInfoCard(race: race)
                        }
                    }
                    .padding(.horizontal, 12)
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
        .onChange(of: timeRemaining) { _, newVal in
            if newVal <= 0 {
                Task { await NextRaceLiveActivityManager.endAll() }
            }
        }
    }
    
    private func loadData() async {
        isLoading = true
        errorMessage = nil
        
        async let nextRaceTask = F1DataService.shared.fetchNextRace()
        async let standingsTask = F1DataService.shared.fetchStandings()
        
        let (race, standingsResult) = await (nextRaceTask, standingsTask)
        
        await MainActor.run {
            if let race = race {
                self.nextRace = race
            } else {
                self.nextRace = F1DataService.shared.createFallbackRace()
            }
            
            self.standings = standingsResult.standings
            self.standingsSeason = standingsResult.season
            self.isLoading = false
            updateCountdown()
            
            if standingsResult.standings.isEmpty {
                self.errorMessage = "Unable to load standings data. Please check your connection."
            }
            
            if let r = self.nextRace {
                WidgetDataStore.save(nextRace: r)
                let remindersOn = UserDefaults.standard.object(forKey: "raceRemindersEnabled") as? Bool ?? true
                let liveOn = UserDefaults.standard.object(forKey: "liveActivitiesEnabled") as? Bool ?? true
                Task {
                    await NotificationManager.scheduleRaceReminders(for: r, enabled: remindersOn)
                    await NextRaceLiveActivityManager.syncLiveActivity(for: r, enabled: liveOn)
                }
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
    var body: some View {
        HStack {
            Image("f1-logo")
                .resizable()
                .scaledToFit()
                .frame(height: 24)
            Spacer()
        }
        .padding(.horizontal, 0)
    }
}

// MARK: - Premium Next Race Card Skeleton
struct PremiumNextRaceCardSkeleton: View {
    var body: some View {
        ZStack {
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
                    .font(AppFont.orbitron(24, weight: .heavy))
                    .foregroundColor(.white)
                    .tracking(2)
                
                VStack(spacing: 8) {
                    Text("Loading...")
                        .font(AppFont.orbitron(22, weight: .bold))
                        .foregroundColor(.white.opacity(0.6))
                    
                    Text("Fetching race data")
                        .font(AppFont.orbitron(15, weight: .regular))
                        .foregroundColor(.white.opacity(0.5))
                }
                
                HStack(spacing: 5) {
                    ForEach(0..<4, id: \.self) { _ in
                        VStack(spacing: 6) {
                            Text("--")
                                .font(AppFont.orbitron(42, weight: .heavy))
                                .foregroundColor(.white.opacity(0.3))
                            
                            Text("---")
                                .font(AppFont.orbitron(11, weight: .regular))
                                .foregroundColor(.white.opacity(0.3))
                        }
                        .frame(minWidth: 50)
                    }
                }
                .padding(.vertical, 20)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 22)
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
                    .font(AppFont.orbitron(24, weight: .heavy))
                    .foregroundColor(.white)
                    .tracking(2)
                
                VStack(spacing: 8) {
                    Text(race.raceName)
                        .font(AppFont.orbitron(22, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(race.circuit.circuitName)
                        .font(AppFont.orbitron(15, weight: .regular))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                PremiumCountdownView(timeRemaining: timeRemaining)

                HStack(spacing: 0) {
                    CircuitDetailItem(icon: "stopwatch.fill", label: "Laps", value: "58")
                        .frame(maxWidth: .infinity)
                    Rectangle()
                        .fill(Color.white.opacity(0.12))
                        .frame(width: 1)
                        .padding(.vertical, 6)
                    CircuitDetailItem(icon: "ruler.fill", label: "Length", value: "5.278 km")
                        .frame(maxWidth: .infinity)
                }
                .padding(.top, 12)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 22)
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
        VStack(spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.f1Red)
                Text(label)
                    .font(AppFont.orbitron(12, weight: .regular))
                    .foregroundColor(.white.opacity(0.65))
            }
            .frame(maxWidth: .infinity, alignment: .center)
            Text(value)
                .font(AppFont.orbitron(17, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.85)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Premium Countdown View
struct PremiumCountdownView: View {
    let timeRemaining: TimeInterval

    private var totalSeconds: Int { max(0, Int(timeRemaining)) }
    private var days: Int { totalSeconds / 86_400 }
    /// Hours within the current day when `days > 0`; total hours when last day (`days == 0`).
    private var hoursInDay: Int { (totalSeconds % 86_400) / 3_600 }
    private var minutes: Int { (totalSeconds % 3_600) / 60 }
    private var seconds: Int { totalSeconds % 60 }

    private var colonSeparator: some View {
        Text(":")
            .foregroundColor(.f1Red)
            .font(AppFont.orbitron(32, weight: .heavy))
    }

    var body: some View {
        HStack(spacing: days > 0 ? 5 : 6) {
            if days > 0 {
                PremiumTimeUnit(value: days, label: "DAYS")
                colonSeparator
                PremiumTimeUnit(value: hoursInDay, label: "HRS")
                colonSeparator
                PremiumTimeUnit(value: minutes, label: "MIN")
                colonSeparator
                PremiumTimeUnit(value: seconds, label: "SEC")
            } else {
                PremiumTimeUnit(value: hoursInDay, label: "HRS")
                colonSeparator
                PremiumTimeUnit(value: minutes, label: "MIN")
                colonSeparator
                PremiumTimeUnit(value: seconds, label: "SEC")
            }
        }
        .padding(.vertical, 20)
        .animation(.easeInOut(duration: 0.25), value: days > 0)
    }
}

struct PremiumTimeUnit: View {
    let value: Int
    let label: String
    
    var body: some View {
        VStack(spacing: 6) {
            Text(String(format: "%02d", value))
                .font(AppFont.orbitron(40, weight: .heavy))
                .foregroundColor(.f1Red)
                .shadow(color: .f1Red.opacity(0.8), radius: 15, x: 0, y: 0)
            
            Text(label)
                .font(AppFont.orbitron(10, weight: .regular))
                .foregroundColor(.white.opacity(0.6))
                .tracking(1)
        }
        .frame(minWidth: 50)
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
                    .font(AppFont.orbitron(22, weight: .bold))
                    .foregroundColor(.white)
                
                Spacer()
                
                Text(seasonDisplay)
                    .font(AppFont.orbitron(12, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(8)
            }
            .padding(.horizontal, 0)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(standings) { standing in
                        PremiumDriverCard(standing: standing)
                    }
                }
                .padding(.horizontal, 2)
            }
        }
    }
}

struct PremiumDriverCard: View {
    let standing: DriverStanding
    
    var body: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(standing.positionInt == 1 ?
                          LinearGradient(colors: [Color.yellow.opacity(0.4), Color.yellow.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing) :
                            LinearGradient(colors: [Color.white.opacity(0.15), Color.white.opacity(0.05)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 56, height: 56)
                
                Text("#\(standing.position)")
                    .font(AppFont.orbitron(22, weight: .bold))
                    .foregroundColor(standing.positionInt == 1 ? .yellow : .white)
            }
            
            Text(standing.driver.fullName)
                .font(AppFont.orbitron(16, weight: .semibold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(height: 40)
            
            Text("\(standing.points) PTS")
                .font(AppFont.orbitron(20, weight: .heavy))
                .foregroundColor(.f1Red)
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
                    .font(AppFont.orbitron(20, weight: .bold))
                    .foregroundColor(.white)
            }
            
            Divider()
                .background(Color.white.opacity(0.2))
            
            HStack(spacing: 24) {
                CircuitInfoRow(icon: "stopwatch.fill", label: "Laps", value: "58")
                CircuitInfoRow(icon: "ruler.fill", label: "Length", value: "5.278 km")
            }
            
            HStack {
                Image(systemName: "location.fill")
                    .foregroundColor(.f1Red.opacity(0.7))
                    .font(.caption)
                
                Text("\(race.circuit.location.locality), \(race.circuit.location.country)")
                    .font(AppFont.orbitron(12, weight: .regular))
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 22)
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
                    .font(AppFont.orbitron(12, weight: .regular))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Text(value)
                .font(AppFont.orbitron(17, weight: .bold))
                .foregroundColor(.white)
        }
    }
}

#Preview {
    HomeView()
}

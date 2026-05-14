//
//  RacesView.swift
//  F1-Dashboard
//
//  Created by Onur Akyüz on 4.01.2026.
//

import SwiftUI

struct RacesView: View {
    @State private var races: [Race] = []
    @State private var winnersByRound: [String: String] = [:]
    @State private var isLoading = true
    
    private var seasonYear: Int {
        if let s = races.first?.season, let y = Int(s) { return y }
        return Calendar.current.component(.year, from: Date())
    }
    
    var body: some View {
        ZStack {
            Color.darkBackground.ignoresSafeArea()
            
            if isLoading {
                VStack {
                    ProgressView()
                        .tint(.f1Red)
                    Text("Loading Race Calendar...")
                        .font(F1Typography.sectionTitle())
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.top, 16)
                }
            } else if races.isEmpty {
                VStack {
                    Image(systemName: "flag.checkered")
                        .font(.system(.largeTitle))
                        .foregroundColor(.f1Red.opacity(0.5))
                    Text("No races available")
                        .font(F1Typography.sectionTitle())
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.top, 16)
                }
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Race Schedule")
                                .font(F1Typography.displayLarge())
                                .foregroundColor(.white)
                                .f1DisplayStyle()
                            
                            Text("\(seasonYear) Formula 1 World Championship")
                                .font(AppFont.orbitron(15, weight: .medium))
                                .foregroundColor(.white.opacity(0.55))
                        }
                        .padding(.horizontal, 4)
                        
                        LazyVStack(spacing: 16) {
                            ForEach(races) { race in
                                PremiumRaceCard(
                                    race: race,
                                    winnerName: winnersByRound[race.round]
                                )
                            }
                        }
                        
                        AttributionFooter()
                            .padding(.top, 12)
                            .padding(.bottom, 100)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 20)
                }
            }
        }
        .task {
            await loadData()
        }
    }
    
    private func loadData() async {
        isLoading = true
        async let scheduleTask = F1DataService.shared.fetchSchedule()
        async let winnersTask = F1DataService.shared.fetchWinnersByRound()
        
        let (fetchedRaces, winners) = await (scheduleTask, winnersTask)
        
        await MainActor.run {
            self.races = fetchedRaces.sorted { race1, race2 in
                guard let date1 = race1.raceDate, let date2 = race2.raceDate else { return false }
                return date1 < date2
            }
            self.winnersByRound = winners
            self.isLoading = false
        }
    }
}

// MARK: - Premium Race Card
private enum RaceCardDateFormatters {
    static let day: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone.current
        f.dateFormat = "MMM dd, yyyy"
        return f
    }()
    
    static let timeOnly: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US_POSIX")
        f.timeZone = TimeZone.current
        f.dateStyle = .none
        f.timeStyle = .short
        return f
    }()
}

struct PremiumRaceCard: View {
    let race: Race
    /// From `current/results.json`, keyed by `round`.
    var winnerName: String?
    
    var isUpcoming: Bool {
        guard let raceDate = race.raceDate else { return false }
        return raceDate > Date()
    }
    
    var isPast: Bool {
        guard let raceDate = race.raceDate else { return false }
        return raceDate < Date()
    }
    
    var formattedDateLine: String {
        guard let raceDate = race.raceDate else { return "TBD" }
        let day = RaceCardDateFormatters.day.string(from: raceDate)
        let time = RaceCardDateFormatters.timeOnly.string(from: raceDate)
        return "\(day) • \(time)"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center) {
                HStack(spacing: 8) {
                    Image(systemName: "flag.checkered.2.crossed")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.f1Red)
                    Text("Round \(race.round)")
                        .font(AppFont.orbitron(12, weight: .bold))
                        .foregroundColor(.white.opacity(0.75))
                        .textCase(.uppercase)
                        .tracking(F1Typography.labelTracking)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.08))
                .cornerRadius(10)
                
                Spacer()
                
                Text(isUpcoming ? "UPCOMING" : "COMPLETED")
                    .font(AppFont.orbitron(11, weight: .heavy))
                    .foregroundColor(isUpcoming ? .f1Red : .white.opacity(0.45))
                    .tracking(1)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        (isUpcoming ? Color.f1Red : Color.white.opacity(0.2)).opacity(isUpcoming ? 0.18 : 0.12)
                    )
                    .cornerRadius(10)
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
            .padding(.bottom, 16)
            
            Divider()
                .background(Color.white.opacity(0.1))
                .padding(.horizontal, 20)
            
            VStack(spacing: 8) {
                Text(race.raceName)
                    .font(AppFont.orbitron(22, weight: .heavy))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.85)
                
                HStack(spacing: 6) {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.f1Red.opacity(0.85))
                    Text(race.circuit.circuitName)
                        .font(AppFont.orbitron(14, weight: .medium))
                        .foregroundColor(.white.opacity(0.65))
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            
            Divider()
                .background(Color.white.opacity(0.1))
                .padding(.horizontal, 20)
            
            HStack(spacing: 10) {
                Image(systemName: "calendar")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.f1Red.opacity(0.85))
                Text(formattedDateLine)
                    .font(AppFont.orbitron(14, weight: .medium))
                    .monospacedDigit()
                    .foregroundColor(.white.opacity(0.85))
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 14)
            
            if isPast, let winner = winnerName, !winner.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "trophy.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color(hex: "E8C547"))
                    Text("Winner: \(winner)")
                        .font(AppFont.orbitron(14, weight: .semibold))
                        .foregroundColor(Color(hex: "E8C547"))
                    Spacer(minLength: 0)
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
            }
            
            HStack(spacing: 6) {
                Image(systemName: "location.fill")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.f1Red.opacity(0.75))
                Text("\(race.circuit.location.locality), \(race.circuit.location.country)")
                    .font(AppFont.orbitron(12, weight: .medium))
                    .foregroundColor(.white.opacity(0.5))
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 10)
            .padding(.bottom, 20)
        }
        .glassCard()
        .opacity(isPast ? 0.92 : 1.0)
    }
}

#Preview {
    RacesView()
}

//
//  ContentView.swift
//  F1-Dashboard
//
//  Created by Onur Akyüz on 4.01.2026.
//

import SwiftUI
import UIKit

struct ContentView: View {
    var body: some View {
        ZStack {
            Color.darkBackground.ignoresSafeArea()
            
            TabView {
                HomeView()
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }
                
                StandingsView()
                    .tabItem {
                        Label("Standings", systemImage: "list.number")
                    }
                
                RacesView()
                    .tabItem {
                        Label("Races", systemImage: "flag.checkered")
                    }
                
                TeamsView()
                    .tabItem {
                        Label("Teams", systemImage: "person.3.fill")
                    }
                
                AboutView(showDismiss: false)
                    .tabItem {
                        Label("About", systemImage: "info.circle.fill")
                    }
            }
            .tint(.f1Red)
            .onAppear {
                // Customize tab bar appearance
                let appearance = UITabBarAppearance()
                appearance.configureWithOpaqueBackground()
                appearance.backgroundColor = UIColor(Color.darkBackground)
                appearance.shadowColor = UIColor.clear
                
                // Selected item
                appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color.f1Red)
                let orbitronSelected = UIFont(name: "Orbitron-Bold", size: 10) ?? .systemFont(ofSize: 10, weight: .bold)
                let orbitronNormal = UIFont(name: "Orbitron-Regular", size: 10) ?? .systemFont(ofSize: 10)
                appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
                    .foregroundColor: UIColor(Color.f1Red),
                    .font: orbitronSelected,
                ]
                
                appearance.stackedLayoutAppearance.normal.iconColor = UIColor.white.withAlphaComponent(0.6)
                appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                    .foregroundColor: UIColor.white.withAlphaComponent(0.6),
                    .font: orbitronNormal,
                ]
                
                UITabBar.appearance().standardAppearance = appearance
                UITabBar.appearance().scrollEdgeAppearance = appearance
            }
        }
    }
}

#Preview {
    ContentView()
}

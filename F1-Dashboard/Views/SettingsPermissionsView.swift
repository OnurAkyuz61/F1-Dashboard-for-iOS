import ActivityKit
import SwiftUI
import UIKit
import UserNotifications

/// Notification + Live Activity toggles; opens system Settings for fine control.
struct SettingsPermissionsView: View {
    @AppStorage("raceRemindersEnabled") private var raceRemindersEnabled = true
    @AppStorage("liveActivitiesEnabled") private var liveActivitiesEnabled = true
    
    @State private var notificationStatus: UNAuthorizationStatus = .notDetermined
    @State private var liveActivitiesSystemEnabled = true
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Notifications & Live Activities")
                .font(AppFont.orbitron(18, weight: .bold))
                .foregroundStyle(.white)
            
            Text("Turn features on or off here. For OS-level permission, use Open iOS Settings below.")
                .font(AppFont.orbitron(13, weight: .regular))
                .foregroundStyle(.white.opacity(0.55))
            
            Toggle(isOn: $raceRemindersEnabled) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Race reminders")
                        .font(AppFont.orbitron(15, weight: .semibold))
                        .foregroundStyle(.white)
                    Text(statusLine(for: notificationStatus))
                        .font(AppFont.orbitron(11, weight: .regular))
                        .foregroundStyle(.white.opacity(0.45))
                }
            }
            .tint(.f1Red)
            .onChange(of: raceRemindersEnabled) { _, enabled in
                if enabled {
                    Task {
                        _ = await NotificationManager.requestAuthorization()
                        await refreshStatuses()
                    }
                } else {
                    UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                }
            }
            
            Toggle(isOn: $liveActivitiesEnabled) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Live Activities (lock screen)")
                        .font(AppFont.orbitron(15, weight: .semibold))
                        .foregroundStyle(.white)
                    Text(liveActivitiesSystemEnabled ? "Shows next-race countdown on Dynamic Island / lock screen when supported." : "Live Activities are turned off for this app in Settings.")
                        .font(AppFont.orbitron(11, weight: .regular))
                        .foregroundStyle(.white.opacity(0.45))
                }
            }
            .tint(.f1Red)
            .onChange(of: liveActivitiesEnabled) { _, enabled in
                if !enabled {
                    Task { await NextRaceLiveActivityManager.endAll() }
                }
            }
            
            Button(action: openSystemSettings) {
                HStack {
                    Image(systemName: "gearshape.fill")
                    Text("Open iOS Settings")
                        .font(AppFont.orbitron(15, weight: .semibold))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.35))
                }
                .foregroundStyle(.white)
                .padding(14)
                .background(Color.white.opacity(0.08))
                .cornerRadius(12)
            }
        }
        .padding(18)
        .background(Color.white.opacity(0.05))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .cornerRadius(14)
        .task { await refreshStatuses() }
        .onAppear { Task { await refreshStatuses() } }
    }
    
    private func openSystemSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
    
    private func refreshStatuses() async {
        notificationStatus = await NotificationManager.authorizationStatus()
        liveActivitiesSystemEnabled = ActivityAuthorizationInfo().areActivitiesEnabled
    }
    
    private func statusLine(for status: UNAuthorizationStatus) -> String {
        switch status {
        case .authorized: return "Notifications allowed."
        case .denied: return "Notifications denied — enable in iOS Settings."
        case .provisional: return "Delivered quietly (provisional)."
        case .ephemeral: return "Ephemeral authorization."
        case .notDetermined: return "Not asked yet — toggle on to request permission."
        @unknown default: return "Unknown authorization state."
        }
    }
}

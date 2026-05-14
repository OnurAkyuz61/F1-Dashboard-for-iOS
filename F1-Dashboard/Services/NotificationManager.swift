import Foundation
import UserNotifications

@MainActor
enum NotificationManager {
    private static let id24h = "f1.nextRace.reminder24h"
    private static let id1h = "f1.nextRace.reminder1h"
    
    static func requestAuthorization() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }
    
    static func authorizationStatus() async -> UNAuthorizationStatus {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return settings.authorizationStatus
    }
    
    /// Schedules two local reminders before the next race start (24h and 1h), if `enabled` and authorized.
    static func scheduleRaceReminders(for race: Race, enabled: Bool) async {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [id24h, id1h])
        
        guard enabled, let start = race.raceDate else { return }
        let status = await authorizationStatus()
        guard status == .authorized || status == .provisional else { return }
        
        let t24 = start.addingTimeInterval(-86400)
        let t1 = start.addingTimeInterval(-3600)
        let now = Date()
        
        if t24 > now {
            await addRequest(
                id: id24h,
                title: "Grand Prix soon",
                body: "\(race.raceName) is in 24 hours.",
                fireDate: t24,
                center: center
            )
        }
        if t1 > now {
            await addRequest(
                id: id1h,
                title: "Race weekend",
                body: "\(race.raceName) starts in 1 hour.",
                fireDate: t1,
                center: center
            )
        }
    }
    
    private static func addRequest(id: String, title: String, body: String, fireDate: Date, center: UNUserNotificationCenter) async {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let comps = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: fireDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        do {
            try await center.add(request)
        } catch {
            print("DEBUG: failed to schedule notification \(id): \(error)")
        }
    }
}

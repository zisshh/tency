import Foundation
import UserNotifications

/// Days-of-week reminder bitmask. Bit 0 = Monday … bit 6 = Sunday.
enum ReminderDays {
  static let symbols = ["M", "T", "W", "T", "F", "S", "S"]  // Mon-first
  static let everyDay = 0b1111111  // 127

  static func isOn(_ bit: Int, in mask: Int) -> Bool { mask & (1 << bit) != 0 }
  static func toggled(_ bit: Int, in mask: Int) -> Int { mask ^ (1 << bit) }
  static func selectedBits(_ mask: Int) -> [Int] { (0..<7).filter { isOn($0, in: mask) } }

  /// Calendar weekday (1 = Sunday … 7 = Saturday) for a Mon-first bit index.
  static func calendarWeekday(forBit bit: Int) -> Int { bit == 6 ? 1 : bit + 2 }
}

/// Schedules per-habit local reminders. No entitlement / paid account required.
@MainActor
enum NotificationService {
  static func requestAuthorization() async -> Bool {
    (try? await UNUserNotificationCenter.current()
      .requestAuthorization(options: [.alert, .sound, .badge])) ?? false
  }

  /// Cancel and re-create a habit's reminders from its `reminderTime` + `reminderDays`.
  static func reschedule(_ habit: Habit) {
    cancel(habitID: habit.id)
    guard let time = habit.reminderTime else { return }
    let bits = ReminderDays.selectedBits(habit.reminderDays)
    guard !bits.isEmpty else { return }

    let parts = Calendar.current.dateComponents([.hour, .minute], from: time)
    guard let hour = parts.hour, let minute = parts.minute else { return }

    let content = UNMutableNotificationContent()
    content.title = habit.name
    content.body = "Time to show up. Color the grid."
    content.sound = .default
    content.userInfo = ["habitID": habit.id.uuidString]

    let center = UNUserNotificationCenter.current()
    for bit in bits {
      var components = DateComponents()
      components.hour = hour
      components.minute = minute
      components.weekday = ReminderDays.calendarWeekday(forBit: bit)
      let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
      let request = UNNotificationRequest(
        identifier: identifier(habit.id, bit), content: content, trigger: trigger)
      center.add(request)
    }
  }

  static func cancel(habitID: UUID) {
    let ids = (0..<7).map { identifier(habitID, $0) }
    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ids)
  }

  /// Re-sync all active habits' reminders (call on launch).
  static func rescheduleAll(_ habits: [Habit]) {
    for habit in habits where !habit.isArchived { reschedule(habit) }
  }

  private static func identifier(_ habitID: UUID, _ bit: Int) -> String {
    "habit-\(habitID.uuidString)-\(bit)"
  }
}

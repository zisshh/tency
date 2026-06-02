import Observation
import UserNotifications

/// Receives notification taps and exposes the tapped habit for navigation.
@Observable
@MainActor
final class NotificationRouter: NSObject, UNUserNotificationCenterDelegate {
  var tappedHabitID: UUID?

  override init() {
    super.init()
    UNUserNotificationCenter.current().delegate = self
  }

  /// Show reminders as a banner even when the app is in the foreground.
  nonisolated func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    completionHandler([.banner, .sound])
  }

  /// On tap, record the habit so the UI can navigate to it.
  nonisolated func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    let id = (response.notification.request.content.userInfo["habitID"] as? String).flatMap(UUID.init)
    Task { @MainActor in self.tappedHabitID = id }
    completionHandler()
  }
}

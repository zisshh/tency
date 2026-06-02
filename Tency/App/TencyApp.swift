import SwiftData
import SwiftUI

@main
struct TencyApp: App {
  @State private var themeManager = ThemeManager()
  @State private var notificationRouter = NotificationRouter()
  private let container: ModelContainer

  init() {
    container = TencyStore.makeContainer()
  }

  var body: some Scene {
    WindowGroup {
      RootView()
        .environment(themeManager)
        .environment(notificationRouter)
        .task {
          let habits = (try? container.mainContext.fetch(FetchDescriptor<Habit>())) ?? []
          NotificationService.rescheduleAll(habits)
        }
    }
    .modelContainer(container)
  }
}

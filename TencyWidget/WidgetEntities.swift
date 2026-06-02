import AppIntents
import SwiftData
import WidgetKit

/// A habit exposed to the widget configuration (the "pick a habit" picker).
struct HabitEntity: AppEntity, Identifiable {
  let id: UUID
  let name: String

  static let typeDisplayRepresentation: TypeDisplayRepresentation = "Habit"
  var displayRepresentation: DisplayRepresentation { DisplayRepresentation(title: "\(name)") }
  static let defaultQuery = HabitEntityQuery()
}

struct HabitEntityQuery: EntityQuery {
  @MainActor
  func entities(for identifiers: [HabitEntity.ID]) async throws -> [HabitEntity] {
    allHabits().filter { identifiers.contains($0.id) }
  }

  @MainActor
  func suggestedEntities() async throws -> [HabitEntity] {
    allHabits()
  }

  @MainActor
  private func allHabits() -> [HabitEntity] {
    WidgetSnapshot.read().habits.map { HabitEntity(id: $0.id, name: $0.name) }
  }
}

/// Configuration intent: which habit the widget displays.
struct SelectHabitIntent: WidgetConfigurationIntent {
  static let title: LocalizedStringResource = "Select Habit"
  static let description = IntentDescription("Choose which habit this widget shows.")

  @Parameter(title: "Habit") var habit: HabitEntity?

  init() {}
}

/// Tap-to-check-in from the widget without launching the app.
struct CheckInIntent: AppIntent {
  static let title: LocalizedStringResource = "Check In"

  @Parameter(title: "Habit ID") var habitID: String

  init() {}
  init(habitID: UUID) { self.habitID = habitID.uuidString }

  @MainActor
  func perform() async throws -> some IntentResult {
    guard let uuid = UUID(uuidString: habitID) else { return .result() }
    let context = ModelContext(TencyStore.makeContainer())
    let habits = (try? context.fetch(FetchDescriptor<Habit>())) ?? []
    if let habit = habits.first(where: { $0.id == uuid }) {
      CheckInService.toggleToday(for: habit, in: context)
    }
    WidgetCenter.shared.reloadAllTimelines()
    return .result()
  }
}

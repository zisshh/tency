import Foundation
import SwiftData

/// Builds the SwiftData stack. The on-disk store lives in the shared App Group
/// container so a future widget extension can read the same data; if the group
/// isn't provisioned yet (e.g. early free-signing builds) we fall back to the
/// app-local store so development is never blocked.
enum TencyStore {
  static let appGroupID = "group.com.divs.tency"

  static let schema = Schema([Habit.self, CheckIn.self, HabitCategory.self])

  static func makeContainer(inMemory: Bool = false) -> ModelContainer {
    if inMemory {
      let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
      guard let container = try? ModelContainer(for: schema, configurations: config) else {
        fatalError("Failed to create in-memory ModelContainer")
      }
      return container
    }

    // Preferred: shared App Group store — but only when the group is actually
    // provisioned in the entitlements. SwiftData's `groupContainer:` path calls
    // `fatalError` (not a Swift throw) if the group is missing, so `try?` can't
    // rescue it; we must check availability first.
    let groupAvailable = FileManager.default
      .containerURL(forSecurityApplicationGroupIdentifier: appGroupID) != nil
    if groupAvailable {
      let shared = ModelConfiguration(schema: schema, groupContainer: .identifier(appGroupID))
      if let container = try? ModelContainer(for: schema, configurations: shared) {
        return container
      }
    }

    // Fallback: app-local store.
    let local = ModelConfiguration(schema: schema)
    guard let container = try? ModelContainer(for: schema, configurations: local) else {
      fatalError("Failed to create ModelContainer")
    }
    return container
  }
}

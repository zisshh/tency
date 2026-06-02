import Foundation
import SwiftData

/// A grouping for habits. Named `HabitCategory` (not `Category`) to avoid
/// collisions with framework types.
@Model
final class HabitCategory {
  var id: UUID = UUID()
  var name: String = ""
  var colorKey: String = "gray"
  var icon: String = "folder.fill"
  var sortOrder: Int = 0

  @Relationship(inverse: \Habit.category)
  var habits: [Habit] = []

  init(name: String, colorKey: String = "gray", icon: String = "folder.fill", sortOrder: Int = 0) {
    self.name = name
    self.colorKey = colorKey
    self.icon = icon
    self.sortOrder = sortOrder
  }
}

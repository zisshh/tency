import Foundation
import SwiftData

@Model
final class Habit {
  var id: UUID = UUID()
  var name: String = ""
  /// SF Symbol name.
  var icon: String = "star.fill"
  /// Semantic accent key (e.g. "blue"), resolved against the active theme.
  var colorKey: String = "blue"
  var kind: HabitKind = HabitKind.binary
  var targetPerDay: Double = 1
  /// "min", "ml", "page"… nil for binary habits.
  var unit: String?
  /// Time-of-day for the reminder (date component ignored). nil = no reminder.
  var reminderTime: Date?
  /// Bitmask of weekdays the reminder fires (bit 0 = Monday … bit 6 = Sunday).
  var reminderDays: Int = 0
  var sortOrder: Int = 0
  var createdAt: Date = Date()
  var archivedAt: Date?

  @Relationship(deleteRule: .cascade, inverse: \CheckIn.habit)
  var checkins: [CheckIn] = []

  var category: HabitCategory?

  init(
    name: String,
    icon: String = "star.fill",
    colorKey: String = "blue",
    kind: HabitKind = .binary,
    targetPerDay: Double = 1,
    unit: String? = nil,
    sortOrder: Int = 0
  ) {
    self.name = name
    self.icon = icon
    self.colorKey = colorKey
    self.kind = kind
    self.targetPerDay = targetPerDay
    self.unit = unit
    self.sortOrder = sortOrder
    self.createdAt = Date()
  }

  var isArchived: Bool { archivedAt != nil }

  /// The effective per-day target; binary habits always need exactly 1.
  var effectiveTarget: Double {
    kind == .binary ? 1 : max(targetPerDay, 1)
  }
}

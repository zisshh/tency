import Foundation
import SwiftData

// MARK: - Backup schema (Codable, version-stamped)

struct CategoryBackup: Codable, Sendable {
  var id: UUID
  var name: String
  var colorKey: String
  var icon: String
  var sortOrder: Int
}

struct CheckInBackup: Codable, Sendable {
  var id: UUID
  var date: Date
  var amount: Double
  var note: String?
  var createdAt: Date
}

struct HabitBackup: Codable, Sendable {
  var id: UUID
  var name: String
  var icon: String
  var colorKey: String
  var kind: HabitKind
  var targetPerDay: Double
  var unit: String?
  var reminderTime: Date?
  var reminderDays: Int
  var sortOrder: Int
  var createdAt: Date
  var archivedAt: Date?
  var categoryID: UUID?
  var checkins: [CheckInBackup]
}

struct TencyBackup: Codable, Sendable {
  var version: Int
  var exportedAt: Date
  var categories: [CategoryBackup]
  var habits: [HabitBackup]
}

/// Serializes the whole store to JSON — the local backup safety net (no iCloud).
enum BackupService {
  static let formatVersion = 1

  /// Build a portable snapshot of every category, habit, and check-in as JSON.
  /// Must run on the main actor since it reads SwiftData models.
  @MainActor
  static func exportData(habits: [Habit], categories: [HabitCategory]) throws -> Data {
    let backup = TencyBackup(
      version: formatVersion,
      exportedAt: Date(),
      categories: categories
        .sorted { $0.sortOrder < $1.sortOrder }
        .map {
          CategoryBackup(id: $0.id, name: $0.name, colorKey: $0.colorKey, icon: $0.icon, sortOrder: $0.sortOrder)
        },
      habits: habits
        .sorted { $0.sortOrder < $1.sortOrder }
        .map { habit in
          HabitBackup(
            id: habit.id,
            name: habit.name,
            icon: habit.icon,
            colorKey: habit.colorKey,
            kind: habit.kind,
            targetPerDay: habit.targetPerDay,
            unit: habit.unit,
            reminderTime: habit.reminderTime,
            reminderDays: habit.reminderDays,
            sortOrder: habit.sortOrder,
            createdAt: habit.createdAt,
            archivedAt: habit.archivedAt,
            categoryID: habit.category?.id,
            checkins: habit.checkins
              .sorted { $0.date < $1.date }
              .map {
                CheckInBackup(id: $0.id, date: $0.date, amount: $0.amount, note: $0.note, createdAt: $0.createdAt)
              })
        })

    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
    encoder.dateEncodingStrategy = .iso8601
    return try encoder.encode(backup)
  }
}

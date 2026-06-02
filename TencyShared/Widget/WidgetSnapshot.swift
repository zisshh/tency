import Foundation
import SwiftData
import WidgetKit

/// A single day's logged amount, for the widget's mini heatmap.
struct DayAmount: Codable, Sendable {
  let date: Date
  let amount: Double
}

/// Display-ready data for one habit, read cheaply by the widget.
struct WidgetHabitData: Codable, Sendable, Identifiable {
  let id: UUID
  let name: String
  let icon: String
  let colorKey: String
  let kind: HabitKind
  let target: Double
  let unit: String?
  let todayAmount: Double
  let recent: [DayAmount]

  var totals: [Date: Double] {
    Dictionary(recent.map { ($0.date, $0.amount) }, uniquingKeysWith: +)
  }
}

struct WidgetData: Codable, Sendable {
  var habits: [WidgetHabitData]
}

/// Bridges SwiftData → App Group defaults so the widget never opens a ModelContainer
/// (doing so on every timeline refresh blows the widget's memory budget → crash loop).
@MainActor
enum WidgetSnapshot {
  private static let key = "tency.widgetData"

  /// App side: serialize active habits + recent history to the shared defaults, then reload.
  static func write(context: ModelContext) {
    let calendar = Calendar.current
    let cutoff = calendar.date(byAdding: .day, value: -90, to: Date()) ?? .distantPast
    let descriptor = FetchDescriptor<Habit>(sortBy: [SortDescriptor(\.sortOrder)])
    let habits = ((try? context.fetch(descriptor)) ?? []).filter { $0.archivedAt == nil }

    let data = WidgetData(
      habits: habits.map { habit in
        let totals = HeatmapBuilder.dailyTotals(for: habit, calendar: calendar)
        let recent = totals
          .filter { $0.key >= cutoff }
          .map { DayAmount(date: $0.key, amount: $0.value) }
        return WidgetHabitData(
          id: habit.id, name: habit.name, icon: habit.icon, colorKey: habit.colorKey,
          kind: habit.kind, target: habit.effectiveTarget, unit: habit.unit,
          todayAmount: CheckInService.todayAmount(for: habit, calendar: calendar), recent: recent)
      })

    if let encoded = try? JSONEncoder().encode(data) {
      ThemeManager.sharedDefaults.set(encoded, forKey: key)
    }
    WidgetCenter.shared.reloadAllTimelines()
  }

  /// Widget side: decode the snapshot (no SwiftData).
  static func read() -> WidgetData {
    guard let raw = ThemeManager.sharedDefaults.data(forKey: key),
      let decoded = try? JSONDecoder().decode(WidgetData.self, from: raw)
    else { return WidgetData(habits: []) }
    return decoded
  }
}

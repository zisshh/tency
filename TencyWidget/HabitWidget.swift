import AppIntents
import SwiftData
import SwiftUI
import WidgetKit

struct HabitEntry: TimelineEntry {
  let date: Date
  let habitID: UUID?
  let name: String
  let icon: String
  let colorKey: String
  let kind: HabitKind
  let target: Double
  let unit: String?
  let todayAmount: Double
  let totals: [Date: Double]

  static let empty = HabitEntry(
    date: .now, habitID: nil, name: "No habit", icon: "square.grid.2x2",
    colorKey: "blue", kind: .binary, target: 1, unit: nil, todayAmount: 0, totals: [:])

  static let sample: HabitEntry = {
    let calendar = Calendar.current
    var totals: [Date: Double] = [:]
    for offset in 0..<48 where offset % 3 != 0 {
      if let day = calendar.date(byAdding: .day, value: -offset, to: .now) {
        totals[calendar.startOfDay(for: day)] = 1
      }
    }
    return HabitEntry(
      date: .now, habitID: UUID(), name: "Read", icon: "book.fill",
      colorKey: "orange", kind: .binary, target: 1, unit: nil, todayAmount: 1, totals: totals)
  }()
}

struct HabitProvider: AppIntentTimelineProvider {
  typealias Entry = HabitEntry
  typealias Intent = SelectHabitIntent

  func placeholder(in context: Context) -> HabitEntry { .sample }

  func snapshot(for configuration: SelectHabitIntent, in context: Context) async -> HabitEntry {
    context.isPreview ? .sample : await makeEntry(for: configuration)
  }

  func timeline(for configuration: SelectHabitIntent, in context: Context) async -> Timeline<HabitEntry> {
    let entry = await makeEntry(for: configuration)
    let next = Calendar.current.date(byAdding: .hour, value: 4, to: .now) ?? .now.addingTimeInterval(14400)
    return Timeline(entries: [entry], policy: .after(next))
  }

  @MainActor
  private func makeEntry(for configuration: SelectHabitIntent) -> HabitEntry {
    let habits = WidgetSnapshot.read().habits
    let habit = configuration.habit.flatMap { selected in habits.first { $0.id == selected.id } } ?? habits.first
    guard let habit else { return .empty }
    return HabitEntry(
      date: .now,
      habitID: habit.id,
      name: habit.name,
      icon: habit.icon,
      colorKey: habit.colorKey,
      kind: habit.kind,
      target: habit.target,
      unit: habit.unit,
      todayAmount: habit.todayAmount,
      totals: habit.totals)
  }
}

struct HeatmapWidget: Widget {
  let kind = "TencyHeatmapWidget"

  var body: some WidgetConfiguration {
    AppIntentConfiguration(kind: kind, intent: SelectHabitIntent.self, provider: HabitProvider()) { entry in
      HabitWidgetView(entry: entry)
    }
    .configurationDisplayName("Habit Heatmap")
    .description("Your habit's grid, with one-tap check-in.")
    .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
  }
}

@main
struct TencyWidgetBundle: WidgetBundle {
  var body: some Widget {
    HeatmapWidget()
  }
}

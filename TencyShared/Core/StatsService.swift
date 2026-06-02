import Foundation

/// Streak, consistency, and weekday analytics for a habit.
@MainActor
enum StatsService {
  /// Start-of-day dates where the habit met its target.
  static func completedDays(for habit: Habit, calendar: Calendar) -> Set<Date> {
    let target = habit.effectiveTarget
    let totals = HeatmapBuilder.dailyTotals(for: habit, calendar: calendar)
    return Set(totals.filter { $0.value >= target }.keys)
  }

  /// Consecutive complete days ending today — or yesterday, if today isn't done yet
  /// (so an in-progress day doesn't read as a broken streak).
  static func currentStreak(for habit: Habit, calendar: Calendar, asOf today: Date = Date()) -> Int {
    let done = completedDays(for: habit, calendar: calendar)
    let start = calendar.startOfDay(for: today)

    var day = start
    if !done.contains(start) {
      guard let yesterday = calendar.date(byAdding: .day, value: -1, to: start) else { return 0 }
      day = yesterday
    }

    var streak = 0
    while done.contains(day) {
      streak += 1
      guard let previous = calendar.date(byAdding: .day, value: -1, to: day) else { break }
      day = previous
    }
    return streak
  }

  /// Longest run of consecutive complete days ever recorded.
  static func bestStreak(for habit: Habit, calendar: Calendar) -> Int {
    let days = completedDays(for: habit, calendar: calendar).sorted()
    guard !days.isEmpty else { return 0 }

    var best = 1
    var run = 1
    for index in 1..<days.count {
      let expectedNext = calendar.date(byAdding: .day, value: 1, to: days[index - 1])
      if let expectedNext, calendar.isDate(expectedNext, inSameDayAs: days[index]) {
        run += 1
      } else {
        run = 1
      }
      best = max(best, run)
    }
    return best
  }

  /// Fraction (0...1) of complete days over the trailing window, capped at the habit's age.
  static func consistency(
    for habit: Habit, calendar: Calendar, window: Int = 30, asOf today: Date = Date()
  ) -> Double {
    let done = completedDays(for: habit, calendar: calendar)
    let start = calendar.startOfDay(for: today)
    let created = calendar.startOfDay(for: habit.createdAt)
    let age = (calendar.dateComponents([.day], from: created, to: start).day ?? 0) + 1
    let span = max(1, min(window, age))

    var hits = 0
    for offset in 0..<span {
      guard let day = calendar.date(byAdding: .day, value: -offset, to: start) else { continue }
      if done.contains(calendar.startOfDay(for: day)) { hits += 1 }
    }
    return Double(hits) / Double(span)
  }

  /// Complete-day counts per weekday, ordered to match `calendar.firstWeekday`.
  static func weekdayCounts(for habit: Habit, calendar: Calendar) -> [(weekday: Int, count: Int)] {
    let done = completedDays(for: habit, calendar: calendar)
    var counts: [Int: Int] = [:]
    for day in done {
      counts[calendar.component(.weekday, from: day), default: 0] += 1
    }
    let order = (0..<7).map { ((calendar.firstWeekday - 1 + $0) % 7) + 1 }
    return order.map { (weekday: $0, count: counts[$0] ?? 0) }
  }
}

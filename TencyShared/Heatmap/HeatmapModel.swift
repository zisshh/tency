import Foundation

/// Which heatmap layout a habit card is showing.
enum HeatmapMode: String, CaseIterable, Identifiable, Sendable {
  case year, month
  var id: String { rawValue }
  var label: String { self == .year ? "Year" : "Month" }
}

/// One day in a heatmap grid. `date == nil` marks a blank padding slot.
struct HeatmapCell: Identifiable {
  let id: String
  let date: Date?
  let amount: Double
  let isToday: Bool
  let isFuture: Bool
}

enum HeatmapBuilder {
  /// Sum of all check-in amounts per start-of-day.
  @MainActor
  static func dailyTotals(for habit: Habit, calendar: Calendar) -> [Date: Double] {
    var totals: [Date: Double] = [:]
    for checkin in habit.checkins {
      let day = calendar.startOfDay(for: checkin.date)
      totals[day, default: 0] += checkin.amount
    }
    return totals
  }

  /// GitHub-style columns of weeks; each column holds 7 cells, top = `calendar.firstWeekday`.
  @MainActor
  static func yearColumns(
    for habit: Habit, calendar: Calendar, weeks: Int = 53, endingOn today: Date = Date()
  ) -> [[HeatmapCell]] {
    let totals = dailyTotals(for: habit, calendar: calendar)
    let end = calendar.startOfDay(for: today)
    let approxStart = calendar.date(byAdding: .day, value: -(weeks * 7 - 1), to: end) ?? end
    let firstColumnStart = calendar.dateInterval(of: .weekOfYear, for: approxStart)?.start ?? approxStart

    var columns: [[HeatmapCell]] = []
    var cursor = calendar.startOfDay(for: firstColumnStart)
    while cursor <= end {
      var column: [HeatmapCell] = []
      for offset in 0..<7 {
        guard let day = calendar.date(byAdding: .day, value: offset, to: cursor) else { continue }
        let key = calendar.startOfDay(for: day)
        let future = key > end
        column.append(
          HeatmapCell(
            id: "y\(key.timeIntervalSince1970)",
            date: future ? nil : key,
            amount: totals[key] ?? 0,
            isToday: calendar.isDate(key, inSameDayAs: end),
            isFuture: future))
      }
      columns.append(column)
      guard let next = calendar.date(byAdding: .day, value: 7, to: cursor) else { break }
      cursor = next
    }
    return columns
  }

  /// Calendar weeks (rows of 7) for `month`, with leading/trailing blank cells.
  /// Takes a precomputed totals dict so both the app and the widget can use it.
  static func monthWeeks(totals: [Date: Double], calendar: Calendar, month: Date) -> [[HeatmapCell]] {
    let today = calendar.startOfDay(for: Date())
    guard let interval = calendar.dateInterval(of: .month, for: month),
      let dayCount = calendar.range(of: .day, in: .month, for: month)?.count
    else { return [] }

    let firstOfMonth = interval.start
    let weekday = calendar.component(.weekday, from: firstOfMonth)
    let leading = ((weekday - calendar.firstWeekday) + 7) % 7

    var cells: [HeatmapCell] = []
    for index in 0..<leading {
      cells.append(HeatmapCell(id: "lead\(index)", date: nil, amount: 0, isToday: false, isFuture: false))
    }
    for offset in 0..<dayCount {
      guard let day = calendar.date(byAdding: .day, value: offset, to: firstOfMonth) else { continue }
      let key = calendar.startOfDay(for: day)
      cells.append(
        HeatmapCell(
          id: "m\(key.timeIntervalSince1970)",
          date: key,
          amount: totals[key] ?? 0,
          isToday: calendar.isDate(key, inSameDayAs: today),
          isFuture: key > today))
    }
    while cells.count % 7 != 0 {
      cells.append(HeatmapCell(id: "trail\(cells.count)", date: nil, amount: 0, isToday: false, isFuture: false))
    }
    return stride(from: 0, to: cells.count, by: 7).map { Array(cells[$0..<($0 + 7)]) }
  }

  /// Columns of weekly amounts from a precomputed totals dict (used by the widget,
  /// which carries totals in its timeline entry rather than a SwiftData object).
  /// `nil` marks a future day.
  static func recentColumns(
    totals: [Date: Double], calendar: Calendar, weeks: Int, endingOn today: Date = Date()
  ) -> [[Double?]] {
    let end = calendar.startOfDay(for: today)
    let approxStart = calendar.date(byAdding: .day, value: -(weeks * 7 - 1), to: end) ?? end
    let firstColumnStart = calendar.dateInterval(of: .weekOfYear, for: approxStart)?.start ?? approxStart

    var columns: [[Double?]] = []
    var cursor = calendar.startOfDay(for: firstColumnStart)
    while cursor <= end {
      var column: [Double?] = []
      for offset in 0..<7 {
        guard let day = calendar.date(byAdding: .day, value: offset, to: cursor) else { continue }
        let key = calendar.startOfDay(for: day)
        column.append(key > end ? nil : (totals[key] ?? 0))
      }
      columns.append(column)
      guard let next = calendar.date(byAdding: .day, value: 7, to: cursor) else { break }
      cursor = next
    }
    return columns
  }

  /// Short weekday symbols ordered to match `calendar.firstWeekday` (e.g. M T W T F S S).
  static func weekdaySymbols(_ calendar: Calendar) -> [String] {
    let symbols = calendar.veryShortStandaloneWeekdaySymbols
    let start = calendar.firstWeekday - 1
    return (0..<7).map { symbols[(start + $0) % 7] }
  }
}

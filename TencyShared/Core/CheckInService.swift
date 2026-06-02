import Foundation
import SwiftData

/// Day-scoped check-in logic, shared by the app and (later) the widget intent.
@MainActor
enum CheckInService {
  /// Total amount logged for `habit` on the given day.
  static func todayAmount(for habit: Habit, on day: Date = Date(), calendar: Calendar = .current) -> Double {
    let target = calendar.startOfDay(for: day)
    return habit.checkins
      .filter { calendar.isDate($0.date, inSameDayAs: target) }
      .reduce(0) { $0 + $1.amount }
  }

  /// Adds 1 to today's total (creating the check-in if needed). Returns the new total.
  @discardableResult
  static func addOne(
    to habit: Habit,
    in context: ModelContext,
    on day: Date = Date(),
    calendar: Calendar = .current
  ) -> Double {
    let target = calendar.startOfDay(for: day)
    if let existing = habit.checkins.first(where: { calendar.isDate($0.date, inSameDayAs: target) }) {
      existing.amount += 1
    } else {
      let checkin = CheckIn(date: target, amount: 1)
      checkin.habit = habit
      context.insert(checkin)
    }
    try? context.save()
    WidgetSnapshot.write(context: context)
    return todayAmount(for: habit, on: day, calendar: calendar)
  }

  /// Today's tap behavior: increment while incomplete, clear once complete (so it can be un-done).
  /// Only ever affects today — past and future days are read-only.
  @discardableResult
  static func toggleToday(for habit: Habit, in context: ModelContext, calendar: Calendar = .current) -> Double {
    guard isComplete(habit, calendar: calendar) else {
      return addOne(to: habit, in: context, calendar: calendar)
    }
    let today = calendar.startOfDay(for: Date())
    for checkin in habit.checkins where calendar.isDate(checkin.date, inSameDayAs: today) {
      context.delete(checkin)
    }
    try? context.save()
    WidgetSnapshot.write(context: context)
    return 0
  }

  /// Whether today's total meets the habit's target.
  static func isComplete(_ habit: Habit, on day: Date = Date(), calendar: Calendar = .current) -> Bool {
    todayAmount(for: habit, on: day, calendar: calendar) >= habit.effectiveTarget
  }

  /// Progress toward today's target, clamped to 0...1.
  static func progress(_ habit: Habit, on day: Date = Date(), calendar: Calendar = .current) -> Double {
    let ratio = todayAmount(for: habit, on: day, calendar: calendar) / habit.effectiveTarget
    return min(max(ratio, 0), 1)
  }
}

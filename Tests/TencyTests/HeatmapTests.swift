import Foundation
import SwiftData
import Testing

@testable import Tency

struct HeatmapColorTests {
  @Test func emptyWhenNoAmount() {
    #expect(HeatmapColor.level(amount: 0, target: 5) == 0)
  }

  @Test func levelScalesWithRatio() {
    #expect(HeatmapColor.level(amount: 1, target: 8) == 1)
    #expect(HeatmapColor.level(amount: 4, target: 8) == 2)
    #expect(HeatmapColor.level(amount: 8, target: 8) == 4)
  }

  @Test func levelClampsAboveTarget() {
    #expect(HeatmapColor.level(amount: 99, target: 5) == 4)
  }
}

@MainActor
struct HeatmapBuilderTests {
  private func context() -> ModelContext {
    ModelContext(TencyStore.makeContainer(inMemory: true))
  }

  @Test func monthWeeksCoversEveryDayInSevenColumnRows() {
    let ctx = context()
    let habit = Habit(name: "Read", kind: .amount, targetPerDay: 3)
    ctx.insert(habit)

    var calendar = Calendar(identifier: .gregorian)
    calendar.firstWeekday = 2  // Monday

    // February 2025 has 28 days.
    let feb = DateComponents(calendar: calendar, year: 2025, month: 2, day: 10).date!
    let totals = HeatmapBuilder.dailyTotals(for: habit, calendar: calendar)
    let weeks = HeatmapBuilder.monthWeeks(totals: totals, calendar: calendar, month: feb)

    #expect(weeks.allSatisfy { $0.count == 7 })
    let realDays = weeks.flatMap { $0 }.filter { $0.date != nil }.count
    #expect(realDays == 28)
  }

  @Test func yearColumnsAreSevenTall() {
    let ctx = context()
    let habit = Habit(name: "Run", kind: .binary)
    ctx.insert(habit)
    let columns = HeatmapBuilder.yearColumns(for: habit, calendar: .current)
    #expect(columns.allSatisfy { $0.count == 7 })
    #expect(columns.count >= 52)
  }

  @Test func dailyTotalsAccumulate() {
    let ctx = context()
    let calendar = Calendar.current
    let habit = Habit(name: "Water", kind: .amount, targetPerDay: 8)
    ctx.insert(habit)
    let today = calendar.startOfDay(for: Date())
    for _ in 0..<3 {
      let c = CheckIn(date: today, amount: 2)
      c.habit = habit
      ctx.insert(c)
    }
    #expect(HeatmapBuilder.dailyTotals(for: habit, calendar: calendar)[today] == 6)
  }
}

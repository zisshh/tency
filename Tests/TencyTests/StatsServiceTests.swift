import Foundation
import SwiftData
import Testing

@testable import Tency

@MainActor
struct StatsServiceTests {
  private func context() -> ModelContext {
    ModelContext(TencyStore.makeContainer(inMemory: true))
  }

  private func complete(_ habit: Habit, daysAgo: [Int], in ctx: ModelContext, calendar: Calendar, today: Date) {
    for offset in daysAgo {
      let day = calendar.date(byAdding: .day, value: -offset, to: today)!
      let checkin = CheckIn(date: calendar.startOfDay(for: day), amount: 1)
      checkin.habit = habit
      ctx.insert(checkin)
    }
  }

  @Test func currentStreakCountsConsecutiveDaysEndingToday() {
    let ctx = context()
    let calendar = Calendar(identifier: .gregorian)
    let today = calendar.startOfDay(for: Date())
    let habit = Habit(name: "x", kind: .binary)
    ctx.insert(habit)
    complete(habit, daysAgo: [0, 1, 2], in: ctx, calendar: calendar, today: today)
    #expect(StatsService.currentStreak(for: habit, calendar: calendar, asOf: today) == 3)
  }

  @Test func currentStreakSurvivesAnIncompleteToday() {
    let ctx = context()
    let calendar = Calendar(identifier: .gregorian)
    let today = calendar.startOfDay(for: Date())
    let habit = Habit(name: "x", kind: .binary)
    ctx.insert(habit)
    complete(habit, daysAgo: [1, 2], in: ctx, calendar: calendar, today: today)  // not today
    #expect(StatsService.currentStreak(for: habit, calendar: calendar, asOf: today) == 2)
  }

  @Test func bestStreakFindsLongestRun() {
    let ctx = context()
    let calendar = Calendar(identifier: .gregorian)
    let today = calendar.startOfDay(for: Date())
    let habit = Habit(name: "x", kind: .binary)
    ctx.insert(habit)
    // A 4-day run and a 2-day run, with gaps.
    complete(habit, daysAgo: [10, 9, 8, 7, 3, 2], in: ctx, calendar: calendar, today: today)
    #expect(StatsService.bestStreak(for: habit, calendar: calendar) == 4)
  }

  @Test func amountHabitOnlyCompleteWhenTargetMet() {
    let ctx = context()
    let calendar = Calendar(identifier: .gregorian)
    let today = calendar.startOfDay(for: Date())
    let habit = Habit(name: "Read", kind: .amount, targetPerDay: 3)
    ctx.insert(habit)
    let partial = CheckIn(date: today, amount: 2)
    partial.habit = habit
    ctx.insert(partial)
    #expect(StatsService.currentStreak(for: habit, calendar: calendar, asOf: today) == 0)
    let topUp = CheckIn(date: today, amount: 1)
    topUp.habit = habit
    ctx.insert(topUp)
    #expect(StatsService.currentStreak(for: habit, calendar: calendar, asOf: today) == 1)
  }
}

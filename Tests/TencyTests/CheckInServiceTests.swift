import Foundation
import SwiftData
import Testing

@testable import Tency

@MainActor
struct CheckInServiceTests {
  private func makeContext() -> ModelContext {
    ModelContext(TencyStore.makeContainer(inMemory: true))
  }

  @Test func amountAccumulatesAcrossTaps() {
    let context = makeContext()
    let habit = Habit(name: "Read", kind: .amount, targetPerDay: 3)
    context.insert(habit)

    CheckInService.addOne(to: habit, in: context)
    CheckInService.addOne(to: habit, in: context)
    #expect(CheckInService.todayAmount(for: habit) == 2)
    #expect(CheckInService.isComplete(habit) == false)

    CheckInService.addOne(to: habit, in: context)
    #expect(CheckInService.isComplete(habit) == true)
    #expect(CheckInService.progress(habit) == 1.0)
  }

  @Test func binaryCompletesWithOneTap() {
    let context = makeContext()
    let habit = Habit(name: "Meditate", kind: .binary)
    context.insert(habit)

    #expect(CheckInService.isComplete(habit) == false)
    CheckInService.addOne(to: habit, in: context)
    #expect(CheckInService.isComplete(habit) == true)
  }

  @Test func checkInsAreDayScoped() throws {
    let context = makeContext()
    let calendar = Calendar.current
    let habit = Habit(name: "Walk", kind: .binary)
    context.insert(habit)

    let yesterday = try #require(calendar.date(byAdding: .day, value: -1, to: Date()))
    CheckInService.addOne(to: habit, in: context, on: yesterday)

    #expect(CheckInService.todayAmount(for: habit) == 0)
    #expect(CheckInService.todayAmount(for: habit, on: yesterday) == 1)
  }

  @Test func toggleTodayMarksThenUnmarksBinary() {
    let context = makeContext()
    let habit = Habit(name: "Meditate", kind: .binary)
    context.insert(habit)

    CheckInService.toggleToday(for: habit, in: context)
    #expect(CheckInService.isComplete(habit) == true)

    CheckInService.toggleToday(for: habit, in: context)
    #expect(CheckInService.isComplete(habit) == false)
    #expect(CheckInService.todayAmount(for: habit) == 0)
  }

  @Test func toggleTodayAccumulatesThenResetsForAmount() {
    let context = makeContext()
    let habit = Habit(name: "Read", kind: .amount, targetPerDay: 2)
    context.insert(habit)

    CheckInService.toggleToday(for: habit, in: context)
    #expect(CheckInService.todayAmount(for: habit) == 1)

    CheckInService.toggleToday(for: habit, in: context)
    #expect(CheckInService.isComplete(habit) == true)

    CheckInService.toggleToday(for: habit, in: context)
    #expect(CheckInService.todayAmount(for: habit) == 0)
  }
}

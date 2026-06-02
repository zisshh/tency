import Testing

@testable import Tency

struct ReminderDaysTests {
  @Test func toggleFlipsABit() {
    var mask = 0
    mask = ReminderDays.toggled(0, in: mask)
    #expect(ReminderDays.isOn(0, in: mask))
    mask = ReminderDays.toggled(0, in: mask)
    #expect(!ReminderDays.isOn(0, in: mask))
  }

  @Test func everyDaySelectsAllSeven() {
    #expect(ReminderDays.selectedBits(ReminderDays.everyDay).count == 7)
    #expect(ReminderDays.selectedBits(0).isEmpty)
  }

  @Test func bitsMapToCalendarWeekdays() {
    // Mon-first bits → Gregorian weekday (1 = Sun … 7 = Sat).
    #expect(ReminderDays.calendarWeekday(forBit: 0) == 2)  // Monday
    #expect(ReminderDays.calendarWeekday(forBit: 4) == 6)  // Friday
    #expect(ReminderDays.calendarWeekday(forBit: 5) == 7)  // Saturday
    #expect(ReminderDays.calendarWeekday(forBit: 6) == 1)  // Sunday
  }
}

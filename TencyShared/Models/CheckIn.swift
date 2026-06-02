import Foundation
import SwiftData

@Model
final class CheckIn {
  var id: UUID = UUID()
  /// Start-of-day in the user's calendar that this check-in counts toward.
  var date: Date = Date()
  /// 1.0 for a binary tap; the logged value for an amount habit.
  var amount: Double = 1
  var note: String?
  var createdAt: Date = Date()

  var habit: Habit?

  init(date: Date, amount: Double = 1, note: String? = nil) {
    self.date = date
    self.amount = amount
    self.note = note
    self.createdAt = Date()
  }
}

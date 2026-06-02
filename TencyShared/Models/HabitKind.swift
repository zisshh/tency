import Foundation

/// How a habit is measured.
enum HabitKind: String, Codable, CaseIterable, Identifiable, Sendable {
  /// Did it / didn't do it. One tap = done.
  case binary
  /// A countable amount (minutes, pages, ml…) toward a daily target.
  case amount

  var id: String { rawValue }

  var label: String {
    switch self {
    case .binary: "Yes / No"
    case .amount: "Amount"
    }
  }
}

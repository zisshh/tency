import Foundation

extension Double {
  /// Drops a trailing `.0` so 3.0 prints as "3" but 2.5 stays "2.5".
  var clean: String {
    self == rounded() ? String(Int(self)) : String(format: "%.1f", self)
  }
}

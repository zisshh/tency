import SwiftUI

extension Color {
  /// Create a Color from a 24-bit RGB hex value, e.g. `Color(hex: 0x83A598)`.
  init(hex: UInt, opacity: Double = 1) {
    let r = Double((hex >> 16) & 0xFF) / 255
    let g = Double((hex >> 8) & 0xFF) / 255
    let b = Double(hex & 0xFF) / 255
    self.init(.sRGB, red: r, green: g, blue: b, opacity: opacity)
  }
}

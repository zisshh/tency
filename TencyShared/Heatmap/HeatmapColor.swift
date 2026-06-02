import SwiftUI
import UIKit

/// Maps a day's logged amount (vs. target) to a heatmap cell color.
enum HeatmapColor {
  /// Intensity bucket: 0 = empty, 1...4 = increasing fill.
  static func level(amount: Double, target: Double) -> Int {
    guard amount > 0 else { return 0 }
    let ratio = min(amount / max(target, 1), 1)
    return max(1, min(Int(ceil(ratio * 4)), 4))
  }

  /// Cell fill for a day, blended over the card's elevated surface toward the habit accent.
  static func cell(amount: Double, target: Double, palette: ThemePalette, accentKey: String) -> Color {
    let step = level(amount: amount, target: target)
    guard step > 0 else { return empty(palette) }
    let fractions = [0.0, 0.45, 0.62, 0.8, 1.0]
    return blend(from: palette.surfaceElevated, to: palette.accent(accentKey), fraction: fractions[step])
  }

  /// Color for a day with no activity.
  static func empty(_ palette: ThemePalette) -> Color {
    palette.textSecondary.opacity(0.14)
  }

  /// Linear RGB interpolation between two colors.
  static func blend(from: Color, to: Color, fraction: Double) -> Color {
    let f = CGFloat(min(max(fraction, 0), 1))
    var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
    var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
    UIColor(from).getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
    UIColor(to).getRed(&r2, green: &g2, blue: &b2, alpha: &a2)
    return Color(
      red: Double(r1 + (r2 - r1) * f),
      green: Double(g1 + (g2 - g1) * f),
      blue: Double(b1 + (b2 - b1) * f))
  }
}

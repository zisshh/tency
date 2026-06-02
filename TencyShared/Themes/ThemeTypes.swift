import SwiftUI

/// Semantic accent keys every theme must define. A habit stores one of these
/// keys, so swapping themes remaps its color by meaning (red → red).
let accentKeys = ["red", "orange", "yellow", "green", "teal", "blue", "purple", "pink"]

/// One concrete set of colors (a single light or dark variant).
struct ThemePalette: Equatable, Sendable {
  let background: Color
  let surface: Color
  let surfaceElevated: Color
  let textPrimary: Color
  let textSecondary: Color
  let accents: [String: Color]
  let tintKey: String

  var tint: Color { accents[tintKey] ?? .accentColor }

  func accent(_ key: String) -> Color { accents[key] ?? tint }

  /// Accents in canonical key order, skipping any that are missing.
  func orderedAccents() -> [(key: String, color: Color)] {
    accentKeys.compactMap { key in accents[key].map { (key, $0) } }
  }
}

/// A theme family with light + dark variants.
struct Theme: Identifiable, Sendable {
  let id: ThemeID
  let name: String
  let blurb: String
  let light: ThemePalette
  let dark: ThemePalette
}

enum ThemeID: String, CaseIterable, Identifiable, Hashable, Sendable {
  case gruvbox, catppuccin, nord, tokyoNight, rosePine, system
  var id: String { rawValue }
}

/// Light/dark resolution preference, independent of the chosen theme.
enum Appearance: String, CaseIterable, Identifiable, Sendable {
  case system, light, dark
  var id: String { rawValue }

  var label: String {
    switch self {
    case .system: "System"
    case .light: "Light"
    case .dark: "Dark"
    }
  }
}

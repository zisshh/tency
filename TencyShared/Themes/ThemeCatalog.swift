import SwiftUI
import UIKit

/// All shipping themes and their hand-tuned palettes.
enum ThemeCatalog {
  static func theme(_ id: ThemeID) -> Theme {
    switch id {
    case .gruvbox: gruvbox
    case .catppuccin: catppuccin
    case .nord: nord
    case .tokyoNight: tokyoNight
    case .rosePine: rosePine
    case .system: system
    }
  }

  static let all: [Theme] = ThemeID.allCases.map(theme)

  // MARK: - Gruvbox

  static let gruvbox = Theme(
    id: .gruvbox,
    name: "Gruvbox",
    blurb: "Warm retro earth tones",
    light: ThemePalette(
      background: Color(hex: 0xFBF1C7),
      surface: Color(hex: 0xEBDBB2),
      surfaceElevated: Color(hex: 0xF2E5BC),
      textPrimary: Color(hex: 0x3C3836),
      textSecondary: Color(hex: 0x7C6F64),
      accents: [
        "red": Color(hex: 0xCC241D), "orange": Color(hex: 0xD65D0E),
        "yellow": Color(hex: 0xD79921), "green": Color(hex: 0x98971A),
        "teal": Color(hex: 0x689D6A), "blue": Color(hex: 0x458588),
        "purple": Color(hex: 0xB16286), "pink": Color(hex: 0x8F3F71),
      ],
      tintKey: "orange"),
    dark: ThemePalette(
      background: Color(hex: 0x282828),
      surface: Color(hex: 0x3C3836),
      surfaceElevated: Color(hex: 0x504945),
      textPrimary: Color(hex: 0xEBDBB2),
      textSecondary: Color(hex: 0xA89984),
      accents: [
        "red": Color(hex: 0xFB4934), "orange": Color(hex: 0xFE8019),
        "yellow": Color(hex: 0xFABD2F), "green": Color(hex: 0xB8BB26),
        "teal": Color(hex: 0x8EC07C), "blue": Color(hex: 0x83A598),
        "purple": Color(hex: 0xD3869B), "pink": Color(hex: 0xE091A8),
      ],
      tintKey: "orange"))

  // MARK: - Catppuccin (Latte / Mocha)

  static let catppuccin = Theme(
    id: .catppuccin,
    name: "Catppuccin",
    blurb: "Soothing pastels",
    light: ThemePalette(
      background: Color(hex: 0xEFF1F5),
      surface: Color(hex: 0xE6E9EF),
      surfaceElevated: Color(hex: 0xCCD0DA),
      textPrimary: Color(hex: 0x4C4F69),
      textSecondary: Color(hex: 0x6C6F85),
      accents: [
        "red": Color(hex: 0xD20F39), "orange": Color(hex: 0xFE640B),
        "yellow": Color(hex: 0xDF8E1D), "green": Color(hex: 0x40A02B),
        "teal": Color(hex: 0x179299), "blue": Color(hex: 0x1E66F5),
        "purple": Color(hex: 0x8839EF), "pink": Color(hex: 0xEA76CB),
      ],
      tintKey: "purple"),
    dark: ThemePalette(
      background: Color(hex: 0x1E1E2E),
      surface: Color(hex: 0x313244),
      surfaceElevated: Color(hex: 0x45475A),
      textPrimary: Color(hex: 0xCDD6F4),
      textSecondary: Color(hex: 0xA6ADC8),
      accents: [
        "red": Color(hex: 0xF38BA8), "orange": Color(hex: 0xFAB387),
        "yellow": Color(hex: 0xF9E2AF), "green": Color(hex: 0xA6E3A1),
        "teal": Color(hex: 0x94E2D5), "blue": Color(hex: 0x89B4FA),
        "purple": Color(hex: 0xCBA6F7), "pink": Color(hex: 0xF5C2E7),
      ],
      tintKey: "purple"))

  // MARK: - Nord

  static let nord = Theme(
    id: .nord,
    name: "Nord",
    blurb: "Cool arctic frost",
    light: ThemePalette(
      background: Color(hex: 0xECEFF4),
      surface: Color(hex: 0xE5E9F0),
      surfaceElevated: Color(hex: 0xD8DEE9),
      textPrimary: Color(hex: 0x2E3440),
      textSecondary: Color(hex: 0x4C566A),
      accents: [
        "red": Color(hex: 0xBF616A), "orange": Color(hex: 0xD08770),
        "yellow": Color(hex: 0xEBCB8B), "green": Color(hex: 0xA3BE8C),
        "teal": Color(hex: 0x8FBCBB), "blue": Color(hex: 0x5E81AC),
        "purple": Color(hex: 0xB48EAD), "pink": Color(hex: 0xC895BF),
      ],
      tintKey: "blue"),
    dark: ThemePalette(
      background: Color(hex: 0x2E3440),
      surface: Color(hex: 0x3B4252),
      surfaceElevated: Color(hex: 0x434C5E),
      textPrimary: Color(hex: 0xECEFF4),
      textSecondary: Color(hex: 0xD8DEE9),
      accents: [
        "red": Color(hex: 0xBF616A), "orange": Color(hex: 0xD08770),
        "yellow": Color(hex: 0xEBCB8B), "green": Color(hex: 0xA3BE8C),
        "teal": Color(hex: 0x8FBCBB), "blue": Color(hex: 0x88C0D0),
        "purple": Color(hex: 0xB48EAD), "pink": Color(hex: 0xD8A8D0),
      ],
      tintKey: "blue"))

  // MARK: - Tokyo Night (Day / Night)

  static let tokyoNight = Theme(
    id: .tokyoNight,
    name: "Tokyo Night",
    blurb: "Neon-noir city lights",
    light: ThemePalette(
      background: Color(hex: 0xE1E2E7),
      surface: Color(hex: 0xD5D6DB),
      surfaceElevated: Color(hex: 0xC4C8DA),
      textPrimary: Color(hex: 0x3760BF),
      textSecondary: Color(hex: 0x6172B0),
      accents: [
        "red": Color(hex: 0xF52A65), "orange": Color(hex: 0xB15C00),
        "yellow": Color(hex: 0x8C6C3E), "green": Color(hex: 0x587539),
        "teal": Color(hex: 0x007197), "blue": Color(hex: 0x2E7DE9),
        "purple": Color(hex: 0x9854F1), "pink": Color(hex: 0xD20065),
      ],
      tintKey: "blue"),
    dark: ThemePalette(
      background: Color(hex: 0x1A1B26),
      surface: Color(hex: 0x24283B),
      surfaceElevated: Color(hex: 0x292E42),
      textPrimary: Color(hex: 0xC0CAF5),
      textSecondary: Color(hex: 0x565F89),
      accents: [
        "red": Color(hex: 0xF7768E), "orange": Color(hex: 0xFF9E64),
        "yellow": Color(hex: 0xE0AF68), "green": Color(hex: 0x9ECE6A),
        "teal": Color(hex: 0x73DACA), "blue": Color(hex: 0x7AA2F7),
        "purple": Color(hex: 0xBB9AF7), "pink": Color(hex: 0xFF75A0),
      ],
      tintKey: "blue"))

  // MARK: - Rosé Pine (Dawn / Main)

  static let rosePine = Theme(
    id: .rosePine,
    name: "Rosé Pine",
    blurb: "Muted vintage rose",
    light: ThemePalette(
      background: Color(hex: 0xFAF4ED),
      surface: Color(hex: 0xFFFAF3),
      surfaceElevated: Color(hex: 0xF2E9E1),
      textPrimary: Color(hex: 0x575279),
      textSecondary: Color(hex: 0x797593),
      accents: [
        "red": Color(hex: 0xB4637A), "orange": Color(hex: 0xEA9D34),
        "yellow": Color(hex: 0xD7A93B), "green": Color(hex: 0x6E9B86),
        "teal": Color(hex: 0x56949F), "blue": Color(hex: 0x286983),
        "purple": Color(hex: 0x907AA9), "pink": Color(hex: 0xD7827E),
      ],
      tintKey: "purple"),
    dark: ThemePalette(
      background: Color(hex: 0x191724),
      surface: Color(hex: 0x1F1D2E),
      surfaceElevated: Color(hex: 0x26233A),
      textPrimary: Color(hex: 0xE0DEF4),
      textSecondary: Color(hex: 0x908CAA),
      accents: [
        "red": Color(hex: 0xEB6F92), "orange": Color(hex: 0xF6C177),
        "yellow": Color(hex: 0xF2D49B), "green": Color(hex: 0x7FA88B),
        "teal": Color(hex: 0x9CCFD8), "blue": Color(hex: 0x31748F),
        "purple": Color(hex: 0xC4A7E7), "pink": Color(hex: 0xEBBCBA),
      ],
      tintKey: "purple"))

  // MARK: - System (follows iOS semantic colors, auto-adapting light/dark)

  static let systemPalette = ThemePalette(
    background: Color(UIColor.systemBackground),
    surface: Color(UIColor.secondarySystemBackground),
    surfaceElevated: Color(UIColor.tertiarySystemBackground),
    textPrimary: Color(UIColor.label),
    textSecondary: Color(UIColor.secondaryLabel),
    accents: [
      "red": .red, "orange": .orange, "yellow": .yellow, "green": .green,
      "teal": .teal, "blue": .blue, "purple": .purple, "pink": .pink,
    ],
    tintKey: "blue")

  static let system = Theme(
    id: .system,
    name: "System",
    blurb: "Follows iOS colors",
    light: systemPalette,
    dark: systemPalette)
}

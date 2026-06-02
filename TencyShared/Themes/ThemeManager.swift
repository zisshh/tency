import Foundation
import SwiftUI

/// Owns the user's theme + appearance + calendar prefs, persisted to UserDefaults.
/// Plain stored properties (not `@AppStorage`) so `@Observable` reliably drives
/// SwiftUI updates; `didSet` mirrors each change to UserDefaults.
@Observable
@MainActor
final class ThemeManager {
  var themeID: ThemeID = .gruvbox {
    didSet { defaults.set(themeID.rawValue, forKey: Keys.theme) }
  }
  var appearance: Appearance = .system {
    didSet { defaults.set(appearance.rawValue, forKey: Keys.appearance) }
  }
  var weekStartsMonday: Bool = true {
    didSet { defaults.set(weekStartsMonday, forKey: Keys.weekStart) }
  }

  @ObservationIgnored private let defaults: UserDefaults

  /// App Group-backed defaults so the widget reads the same theme; falls back to standard.
  static let sharedDefaults: UserDefaults = UserDefaults(suiteName: TencyStore.appGroupID) ?? .standard

  private enum Keys {
    static let theme = "tency.theme"
    static let appearance = "tency.appearance"
    static let weekStart = "tency.weekStartsMonday"
  }

  init(defaults: UserDefaults = ThemeManager.sharedDefaults) {
    self.defaults = defaults
    if let raw = defaults.string(forKey: Keys.theme), let id = ThemeID(rawValue: raw) {
      themeID = id
    }
    if let raw = defaults.string(forKey: Keys.appearance), let value = Appearance(rawValue: raw) {
      appearance = value
    }
    if let stored = defaults.object(forKey: Keys.weekStart) as? Bool {
      weekStartsMonday = stored
    }
  }

  var theme: Theme { ThemeCatalog.theme(themeID) }

  /// Resolve the concrete palette given the live system color scheme.
  func palette(for systemScheme: ColorScheme) -> ThemePalette {
    let resolved: ColorScheme
    switch appearance {
    case .system: resolved = systemScheme
    case .light: resolved = .light
    case .dark: resolved = .dark
    }
    return resolved == .dark ? theme.dark : theme.light
  }

  /// nil lets the system decide; otherwise forces light or dark.
  var preferredColorScheme: ColorScheme? {
    switch appearance {
    case .system: nil
    case .light: .light
    case .dark: .dark
    }
  }

  /// Gregorian first weekday: 1 = Sunday, 2 = Monday.
  var firstWeekday: Int { weekStartsMonday ? 2 : 1 }

  /// A calendar honoring the user's week-start preference.
  var calendar: Calendar {
    var cal = Calendar.current
    cal.firstWeekday = firstWeekday
    return cal
  }

  /// Resolve the active palette without a ThemeManager instance (used by the widget process).
  @MainActor
  static func resolvedPalette(for systemScheme: ColorScheme) -> ThemePalette {
    let store = sharedDefaults
    let id = ThemeID(rawValue: store.string(forKey: Keys.theme) ?? "") ?? .gruvbox
    let appearance = Appearance(rawValue: store.string(forKey: Keys.appearance) ?? "") ?? .system
    let theme = ThemeCatalog.theme(id)
    let scheme: ColorScheme = appearance == .system ? systemScheme : (appearance == .dark ? .dark : .light)
    return scheme == .dark ? theme.dark : theme.light
  }
}

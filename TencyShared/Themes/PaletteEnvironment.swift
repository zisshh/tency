import SwiftUI

extension EnvironmentValues {
  /// The resolved palette for the active theme + appearance, injected at the root.
  @Entry var palette: ThemePalette = ThemeCatalog.gruvbox.dark
}

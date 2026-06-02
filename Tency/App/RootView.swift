import SwiftUI

struct RootView: View {
  @Environment(ThemeManager.self) private var themeManager
  @Environment(\.colorScheme) private var systemScheme

  private enum AppTab { case habits, settings }
  @State private var selection: AppTab = .habits
  @State private var showSplash = true

  private var palette: ThemePalette { themeManager.palette(for: systemScheme) }

  var body: some View {
    ZStack {
      TabView(selection: $selection) {
        Tab("Habits", systemImage: "square.grid.3x3.fill", value: AppTab.habits) {
          HabitListView()
        }
        Tab("Settings", systemImage: "gearshape.fill", value: AppTab.settings) {
          SettingsView()
        }
      }
      .tint(palette.tint)

      if showSplash {
        SplashView()
          .transition(.opacity)
          .zIndex(1)
      }
    }
    .environment(\.palette, palette)
    .preferredColorScheme(themeManager.preferredColorScheme)
    .task {
      try? await Task.sleep(for: .seconds(1.1))
      withAnimation(.easeOut(duration: 0.45)) { showSplash = false }
    }
  }
}

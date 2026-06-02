import SwiftUI

/// A miniature live preview of a theme's palette, used in the Settings gallery.
struct ThemePreviewCard: View {
  let theme: Theme
  let scheme: ColorScheme
  let selected: Bool

  private var p: ThemePalette { scheme == .dark ? theme.dark : theme.light }

  var body: some View {
    VStack(spacing: 6) {
      ZStack {
        RoundedRectangle(cornerRadius: 14).fill(p.background)
        VStack(alignment: .leading, spacing: 5) {
          RoundedRectangle(cornerRadius: 3).fill(p.surface).frame(width: 52, height: 9)
          RoundedRectangle(cornerRadius: 3).fill(p.surfaceElevated).frame(width: 38, height: 9)
          HStack(spacing: 3) {
            ForEach(Array(p.orderedAccents().prefix(6)), id: \.key) { entry in
              Circle().fill(entry.color).frame(width: 9, height: 9)
            }
          }
        }
        .padding(11)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
      }
      .frame(width: 100, height: 74)
      .overlay {
        RoundedRectangle(cornerRadius: 14)
          .strokeBorder(selected ? p.tint : Color.gray.opacity(0.25), lineWidth: selected ? 3 : 1)
      }

      Text(theme.name)
        .font(.caption)
        .fontWeight(selected ? .semibold : .regular)
    }
  }
}

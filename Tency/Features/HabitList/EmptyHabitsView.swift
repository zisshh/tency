import SwiftUI

struct EmptyHabitsView: View {
  var onAdd: () -> Void
  @Environment(\.palette) private var palette

  var body: some View {
    VStack(spacing: 24) {
      MiniHeatmapDecoration()
        .frame(height: 110)
        .padding(.horizontal, 36)

      VStack(spacing: 8) {
        Text("No habits yet")
          .font(.title2.bold())
          .foregroundStyle(palette.textPrimary)
        Text("Show up. Color the grid.\nTap below to plant your first habit.")
          .font(.subheadline)
          .multilineTextAlignment(.center)
          .foregroundStyle(palette.textSecondary)
      }

      Button(action: onAdd) {
        Label("New habit", systemImage: "plus")
          .font(.headline)
          .padding(.horizontal, 8)
      }
      .buttonStyle(.borderedProminent)
      .tint(palette.tint)
      .controlSize(.large)
    }
    .padding(32)
  }
}

/// A static, pseudo-random grid teaser hinting at the heatmap to come.
private struct MiniHeatmapDecoration: View {
  @Environment(\.palette) private var palette
  private let cols = 14
  private let rows = 5

  var body: some View {
    GeometryReader { geo in
      let spacing: CGFloat = 4
      let cell = max((geo.size.width - spacing * CGFloat(cols - 1)) / CGFloat(cols), 2)
      let accents = palette.orderedAccents().map(\.color)

      VStack(spacing: spacing) {
        ForEach(0..<rows, id: \.self) { row in
          HStack(spacing: spacing) {
            ForEach(0..<cols, id: \.self) { col in
              let seed = (row * 31 + col * 17) % 11
              let base = accents.isEmpty ? palette.tint : accents[(row + col) % accents.count]
              RoundedRectangle(cornerRadius: 3)
                .fill(seed < 4 ? palette.surfaceElevated : base.opacity(Double(seed) / 12.0 + 0.2))
                .frame(width: cell, height: cell)
            }
          }
        }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
  }
}

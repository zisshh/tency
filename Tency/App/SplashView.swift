import SwiftUI

/// Brief branded launch overlay: a heatmap grid pops in, then the name + tagline.
/// Shown over the app for a beat on cold launch, then faded out by `RootView`.
struct SplashView: View {
  @Environment(\.palette) private var palette
  @State private var appeared = false

  var body: some View {
    ZStack {
      palette.background.ignoresSafeArea()
      VStack(spacing: 24) {
        gridLogo
        VStack(spacing: 6) {
          Text("tency")
            .font(.system(size: 36, weight: .bold, design: .rounded))
            .foregroundStyle(palette.textPrimary)
          Text("Show up. Color the grid.")
            .font(.subheadline)
            .foregroundStyle(palette.textSecondary)
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 8)
      }
    }
    .onAppear {
      withAnimation(.easeOut(duration: 0.5).delay(0.25)) { appeared = true }
    }
  }

  private var gridLogo: some View {
    let accents = Array(palette.orderedAccents().prefix(9))
    let side: CGFloat = 38
    let columns = Array(repeating: GridItem(.fixed(side), spacing: 9), count: 3)
    return LazyVGrid(columns: columns, spacing: 9) {
      ForEach(Array(accents.enumerated()), id: \.offset) { index, entry in
        RoundedRectangle(cornerRadius: 9)
          .fill(entry.color)
          .frame(width: side, height: side)
          .opacity(appeared ? 1 : 0)
          .scaleEffect(appeared ? 1 : 0.4)
          .animation(
            .spring(response: 0.45, dampingFraction: 0.62).delay(Double(index) * 0.05),
            value: appeared)
      }
    }
    .frame(width: side * 3 + 18)
  }
}

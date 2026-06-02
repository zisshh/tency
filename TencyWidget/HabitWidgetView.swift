import AppIntents
import SwiftUI
import WidgetKit

struct HabitWidgetView: View {
  let entry: HabitEntry

  @Environment(\.widgetFamily) private var family
  @Environment(\.colorScheme) private var scheme

  private var palette: ThemePalette { ThemeManager.resolvedPalette(for: scheme) }
  private var accent: Color { palette.accent(entry.colorKey) }
  private var complete: Bool { entry.todayAmount >= entry.target }

  private var weeks: Int {
    switch family {
    case .systemSmall: 11
    default: 20
    }
  }

  var body: some View {
    Group {
      if entry.habitID == nil {
        emptyState
      } else {
        VStack(alignment: .leading, spacing: 8) {
          header
          if family == .systemSmall {
            WidgetMonthHeatmap(
              totals: entry.totals, target: entry.target,
              accentKey: entry.colorKey, palette: palette
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
          } else {
            WidgetMiniHeatmap(
              totals: entry.totals, target: entry.target,
              accentKey: entry.colorKey, palette: palette, weeks: weeks
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
          }
        }
      }
    }
    .containerBackground(palette.background, for: .widget)
  }

  private var header: some View {
    HStack(spacing: 8) {
      Image(systemName: entry.icon).font(.headline).foregroundStyle(accent)
      VStack(alignment: .leading, spacing: 0) {
        Text(entry.name).font(.headline).foregroundStyle(palette.textPrimary).lineLimit(1)
        if family != .systemSmall && entry.kind == .amount {
          Text(statusText).font(.caption2).foregroundStyle(palette.textSecondary)
        }
      }
      Spacer(minLength: 4)
      checkButton
    }
  }

  private var emptyState: some View {
    VStack(spacing: 6) {
      Image(systemName: "square.grid.3x3").font(.title2).foregroundStyle(palette.textSecondary)
      Text("Add a habit in tency")
        .font(.caption).foregroundStyle(palette.textSecondary).multilineTextAlignment(.center)
    }
  }

  @ViewBuilder private var checkButton: some View {
    if let id = entry.habitID {
      Button(intent: CheckInIntent(habitID: id)) {
        Image(systemName: complete ? "checkmark.circle.fill" : "plus.circle.fill")
          .font(.title2)
          .symbolRenderingMode(.hierarchical)
          .foregroundStyle(accent)
      }
      .buttonStyle(.plain)
    }
  }

  private var statusText: String {
    switch entry.kind {
    case .binary: complete ? "Done today" : "Not yet today"
    case .amount: "\(entry.todayAmount.clean) / \(entry.target.clean)\(entry.unit.map { " \($0)" } ?? "")"
    }
  }
}

/// Heatmap that fills its container — each cell flexes to share the available space.
struct WidgetMiniHeatmap: View {
  let totals: [Date: Double]
  let target: Double
  let accentKey: String
  let palette: ThemePalette
  let weeks: Int

  var body: some View {
    let columns = HeatmapBuilder.recentColumns(totals: totals, calendar: .current, weeks: weeks)
    HStack(spacing: 3) {
      ForEach(Array(columns.enumerated()), id: \.offset) { _, week in
        VStack(spacing: 3) {
          ForEach(0..<7, id: \.self) { row in
            RoundedRectangle(cornerRadius: 3)
              .fill(color(for: row < week.count ? week[row] : nil))
              .frame(maxWidth: .infinity, maxHeight: .infinity)
          }
        }
      }
    }
  }

  private func color(for amount: Double?) -> Color {
    guard let amount else { return .clear }
    return HeatmapColor.cell(amount: amount, target: target, palette: palette, accentKey: accentKey)
  }
}

/// Current-month calendar with fixed square cells, for the small widget. Today is ringed.
struct WidgetMonthHeatmap: View {
  let totals: [Date: Double]
  let target: Double
  let accentKey: String
  let palette: ThemePalette

  private let side: CGFloat = 18
  private let gap: CGFloat = 2

  var body: some View {
    let weeks = HeatmapBuilder.monthWeeks(totals: totals, calendar: .current, month: Date())
    VStack(spacing: gap) {
      ForEach(Array(weeks.enumerated()), id: \.offset) { _, week in
        HStack(spacing: gap) {
          ForEach(week) { dayCell($0) }
        }
      }
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
  }

  @ViewBuilder private func dayCell(_ item: HeatmapCell) -> some View {
    if item.date != nil {
      RoundedRectangle(cornerRadius: 4)
        .fill(item.isFuture ? HeatmapColor.empty(palette) : HeatmapColor.cell(amount: item.amount, target: target, palette: palette, accentKey: accentKey))
        .frame(width: side, height: side)
        .overlay {
          if item.isToday {
            RoundedRectangle(cornerRadius: 4).strokeBorder(palette.textPrimary.opacity(0.7), lineWidth: 1.5)
          }
        }
    } else {
      Color.clear.frame(width: side, height: side)
    }
  }
}


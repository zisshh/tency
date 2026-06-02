import SwiftUI

/// Switches between the year and month heatmap layouts for a habit.
/// Only today's cell is interactive (toggles done/undone); past + future are read-only.
struct HeatmapView: View {
  let habit: Habit
  let mode: HeatmapMode
  let calendar: Calendar
  let month: Date
  let onToggleToday: () -> Void

  var body: some View {
    switch mode {
    case .year:
      YearHeatmap(habit: habit, calendar: calendar, onToggleToday: onToggleToday)
    case .month:
      MonthHeatmap(habit: habit, calendar: calendar, month: month, onToggleToday: onToggleToday)
    }
  }
}

/// Applies a tap action only to today's cell.
private struct TodayTap: ViewModifier {
  let isToday: Bool
  let action: () -> Void

  func body(content: Content) -> some View {
    if isToday {
      content.onTapGesture(perform: action)
    } else {
      content
    }
  }
}

// MARK: - Year (GitHub-style contribution grid)

private struct YearHeatmap: View {
  let habit: Habit
  let calendar: Calendar
  let onToggleToday: () -> Void

  @Environment(\.palette) private var palette
  private let cell: CGFloat = 12
  private let gap: CGFloat = 3

  var body: some View {
    let columns = HeatmapBuilder.yearColumns(for: habit, calendar: calendar)
    ScrollView(.horizontal, showsIndicators: false) {
      LazyHStack(alignment: .top, spacing: gap) {
        ForEach(Array(columns.enumerated()), id: \.offset) { _, week in
          VStack(spacing: gap) { ForEach(week) { cellView($0) } }
        }
      }
      .padding(.vertical, 2)
    }
    .defaultScrollAnchor(.trailing)
    .frame(height: cell * 7 + gap * 6 + 4)
  }

  @ViewBuilder private func cellView(_ item: HeatmapCell) -> some View {
    if item.isFuture || item.date == nil {
      RoundedRectangle(cornerRadius: 2.5).fill(.clear).frame(width: cell, height: cell)
    } else {
      RoundedRectangle(cornerRadius: 2.5)
        .fill(HeatmapColor.cell(amount: item.amount, target: habit.effectiveTarget, palette: palette, accentKey: habit.colorKey))
        .frame(width: cell, height: cell)
        .overlay {
          if item.isToday {
            RoundedRectangle(cornerRadius: 2.5).strokeBorder(palette.textPrimary.opacity(0.55), lineWidth: 1)
          }
        }
        .modifier(TodayTap(isToday: item.isToday, action: onToggleToday))
    }
  }
}

// MARK: - Month (calendar grid)

private struct MonthHeatmap: View {
  let habit: Habit
  let calendar: Calendar
  let month: Date
  let onToggleToday: () -> Void

  @Environment(\.palette) private var palette
  private let cell: CGFloat = 18
  private let gap: CGFloat = 4

  var body: some View {
    let totals = HeatmapBuilder.dailyTotals(for: habit, calendar: calendar)
    let weeks = HeatmapBuilder.monthWeeks(totals: totals, calendar: calendar, month: month)
    VStack(spacing: gap) {
      HStack(spacing: gap) {
        ForEach(Array(HeatmapBuilder.weekdaySymbols(calendar).enumerated()), id: \.offset) { _, symbol in
          Text(symbol)
            .font(.system(size: 9))
            .foregroundStyle(palette.textSecondary)
            .frame(width: cell)
        }
      }
      ForEach(Array(weeks.enumerated()), id: \.offset) { _, week in
        HStack(spacing: gap) { ForEach(week) { dayCell($0) } }
      }
    }
    .frame(maxWidth: .infinity)
  }

  @ViewBuilder private func dayCell(_ item: HeatmapCell) -> some View {
    if let date = item.date {
      let day = calendar.component(.day, from: date)
      RoundedRectangle(cornerRadius: 4)
        .fill(item.isFuture ? .clear : HeatmapColor.cell(amount: item.amount, target: habit.effectiveTarget, palette: palette, accentKey: habit.colorKey))
        .frame(width: cell, height: cell)
        .overlay {
          Text("\(day)")
            .font(.system(size: 9))
            .foregroundStyle(palette.textPrimary.opacity(item.isFuture ? 0.3 : 0.65))
        }
        .overlay {
          if item.isToday {
            RoundedRectangle(cornerRadius: 4).strokeBorder(palette.textPrimary.opacity(0.65), lineWidth: 1.5)
          }
        }
        .contentShape(.rect)
        .modifier(TodayTap(isToday: item.isToday, action: onToggleToday))
    } else {
      Color.clear.frame(width: cell, height: cell)
    }
  }
}

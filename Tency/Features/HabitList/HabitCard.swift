import SwiftData
import SwiftUI

/// A habit's home-screen card: header + heatmap (year/month) + view controls.
struct HabitCard: View {
  let habit: Habit

  @Environment(\.palette) private var palette
  @Environment(ThemeManager.self) private var themeManager
  @Environment(\.modelContext) private var context

  @State private var mode: HeatmapMode = .year
  @State private var monthAnchor: Date = Date()

  private var accent: Color { palette.accent(habit.colorKey) }
  private var today: Double { CheckInService.todayAmount(for: habit) }
  private var complete: Bool { CheckInService.isComplete(habit) }

  var body: some View {
    VStack(spacing: 12) {
      header
      HeatmapView(habit: habit, mode: mode, calendar: themeManager.calendar, month: monthAnchor) {
        CheckInService.toggleToday(for: habit, in: context)
      }
      footer
    }
    .padding(14)
    .background(palette.surface, in: .rect(cornerRadius: 20))
  }

  private var header: some View {
    HStack(spacing: 14) {
      NavigationLink(value: habit) {
        HStack(spacing: 14) {
          ZStack {
            Circle().fill(accent.opacity(0.18))
            Image(systemName: habit.icon)
              .font(.system(size: 18, weight: .semibold))
              .foregroundStyle(accent)
          }
          .frame(width: 44, height: 44)

          VStack(alignment: .leading, spacing: 2) {
            Text(habit.name).font(.headline).foregroundStyle(palette.textPrimary)
            Text(subtitle).font(.subheadline).foregroundStyle(palette.textSecondary)
          }
        }
      }
      .buttonStyle(.plain)

      Spacer(minLength: 8)

      Button {
        CheckInService.toggleToday(for: habit, in: context)
      } label: {
        Image(systemName: complete ? "checkmark.circle.fill" : "plus.circle.fill")
          .font(.system(size: 30))
          .symbolRenderingMode(.hierarchical)
          .foregroundStyle(accent)
          .contentTransition(.symbolEffect(.replace))
          .symbolEffect(.bounce, value: today)
      }
      .buttonStyle(.plain)
      .tapRipple(trigger: today, color: accent)
      .sensoryFeedback(.increase, trigger: today)
      .accessibilityLabel(complete ? "\(habit.name) done today" : "Add one to \(habit.name)")
    }
  }

  private var footer: some View {
    HStack {
      Picker("View", selection: $mode) {
        ForEach(HeatmapMode.allCases) { Text($0.label).tag($0) }
      }
      .pickerStyle(.segmented)
      .fixedSize()

      Spacer()

      if mode == .month {
        HStack(spacing: 14) {
          Button { shiftMonth(-1) } label: { Image(systemName: "chevron.left") }
          Text(monthLabel).font(.subheadline.weight(.medium)).foregroundStyle(palette.textPrimary)
          Button { shiftMonth(1) } label: { Image(systemName: "chevron.right") }
            .disabled(isCurrentMonth)
        }
        .font(.subheadline)
        .foregroundStyle(palette.textSecondary)
      }
    }
  }

  private var subtitle: String {
    switch habit.kind {
    case .binary:
      complete ? "Done today" : "Not yet today"
    case .amount:
      "\(today.clean) / \(habit.targetPerDay.clean)\(habit.unit.map { " \($0)" } ?? "") today"
    }
  }

  private var monthLabel: String {
    monthAnchor.formatted(.dateTime.month(.abbreviated).year())
  }

  private var isCurrentMonth: Bool {
    themeManager.calendar.isDate(monthAnchor, equalTo: Date(), toGranularity: .month)
  }

  private func shiftMonth(_ delta: Int) {
    if let next = themeManager.calendar.date(byAdding: .month, value: delta, to: monthAnchor) {
      monthAnchor = next
    }
  }
}

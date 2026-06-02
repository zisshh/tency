import SwiftData
import SwiftUI

struct HabitDetailView: View {
  @Bindable var habit: Habit

  @Environment(\.palette) private var palette
  @Environment(ThemeManager.self) private var themeManager
  @Environment(\.modelContext) private var context
  @Environment(\.dismiss) private var dismiss

  @State private var editing = false
  @State private var confirmDelete = false

  private var cal: Calendar { themeManager.calendar }
  private var accent: Color { palette.accent(habit.colorKey) }

  var body: some View {
    ScrollView {
      VStack(spacing: 18) {
        statsRow
        section("Activity") {
          HeatmapView(habit: habit, mode: .year, calendar: cal, month: Date()) {
            CheckInService.toggleToday(for: habit, in: context)
          }
        }
        section("By weekday") {
          WeekdayBars(habit: habit, calendar: cal)
        }
      }
      .padding(16)
    }
    .background(palette.background.ignoresSafeArea())
    .navigationTitle(habit.name)
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        Menu {
          Button { editing = true } label: { Label("Edit", systemImage: "pencil") }
          Button { toggleArchive() } label: {
            Label(habit.isArchived ? "Unarchive" : "Archive", systemImage: "archivebox")
          }
          Button(role: .destructive) { confirmDelete = true } label: {
            Label("Delete", systemImage: "trash")
          }
        } label: {
          Image(systemName: "ellipsis.circle")
        }
      }
    }
    .sheet(isPresented: $editing) { AddHabitView(habit: habit) }
    .alert("Delete \(habit.name)?", isPresented: $confirmDelete) {
      Button("Delete", role: .destructive) { delete() }
      Button("Cancel", role: .cancel) {}
    } message: {
      Text("This removes the habit and all its check-ins. This can't be undone.")
    }
  }

  private var statsRow: some View {
    HStack(spacing: 12) {
      StatTile(icon: "flame.fill", value: "\(StatsService.currentStreak(for: habit, calendar: cal))", label: "Current", accent: accent)
      StatTile(icon: "trophy.fill", value: "\(StatsService.bestStreak(for: habit, calendar: cal))", label: "Best", accent: accent)
      StatTile(
        icon: "chart.line.uptrend.xyaxis",
        value: "\(Int((StatsService.consistency(for: habit, calendar: cal) * 100).rounded()))%",
        label: "30-day", accent: accent)
    }
  }

  @ViewBuilder
  private func section(_ title: String, @ViewBuilder content: () -> some View) -> some View {
    VStack(alignment: .leading, spacing: 12) {
      Text(title).font(.headline).foregroundStyle(palette.textPrimary)
      content()
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(16)
    .background(palette.surface, in: .rect(cornerRadius: 18))
  }

  private func toggleArchive() {
    let nowArchiving = !habit.isArchived
    habit.archivedAt = nowArchiving ? Date() : nil
    try? context.save()
    if nowArchiving {
      NotificationService.cancel(habitID: habit.id)
    } else {
      NotificationService.reschedule(habit)
    }
    WidgetSnapshot.write(context: context)
    if nowArchiving { dismiss() }
  }

  private func delete() {
    NotificationService.cancel(habitID: habit.id)
    context.delete(habit)
    try? context.save()
    WidgetSnapshot.write(context: context)
    dismiss()
  }
}

private struct StatTile: View {
  let icon: String
  let value: String
  let label: String
  let accent: Color
  @Environment(\.palette) private var palette

  var body: some View {
    VStack(spacing: 6) {
      Image(systemName: icon).font(.title3).foregroundStyle(accent)
      Text(value).font(.title2.bold()).foregroundStyle(palette.textPrimary)
      Text(label).font(.caption).foregroundStyle(palette.textSecondary)
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, 16)
    .background(palette.surface, in: .rect(cornerRadius: 18))
  }
}

private struct WeekdayBars: View {
  let habit: Habit
  let calendar: Calendar
  @Environment(\.palette) private var palette

  var body: some View {
    let data = StatsService.weekdayCounts(for: habit, calendar: calendar)
    let maxCount = max(data.map(\.count).max() ?? 1, 1)
    HStack(alignment: .bottom, spacing: 8) {
      ForEach(data, id: \.weekday) { item in
        VStack(spacing: 6) {
          RoundedRectangle(cornerRadius: 4)
            .fill(palette.accent(habit.colorKey))
            .opacity(item.count < 1 ? 0.18 : 1)
            .frame(height: max(4, CGFloat(item.count) / CGFloat(maxCount) * 70))
          Text(symbol(item.weekday)).font(.caption2).foregroundStyle(palette.textSecondary)
        }
        .frame(maxWidth: .infinity)
      }
    }
    .frame(height: 96, alignment: .bottom)
  }

  private func symbol(_ weekday: Int) -> String {
    calendar.veryShortStandaloneWeekdaySymbols[(weekday - 1) % 7]
  }
}

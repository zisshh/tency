import SwiftData
import SwiftUI

struct HabitListView: View {
  @Environment(\.palette) private var palette
  @Environment(\.modelContext) private var context
  @Environment(NotificationRouter.self) private var notificationRouter
  @Query(sort: \Habit.sortOrder, order: .forward) private var habits: [Habit]
  @Query(sort: \HabitCategory.sortOrder, order: .forward) private var categories: [HabitCategory]

  @State private var showingAdd = false
  @State private var selectedCategoryID: UUID?
  @State private var path: [Habit] = []

  private var activeHabits: [Habit] { habits.filter { !$0.isArchived } }

  private var filteredHabits: [Habit] {
    guard let id = selectedCategoryID else { return activeHabits }
    return activeHabits.filter { $0.category?.id == id }
  }

  var body: some View {
    NavigationStack(path: $path) {
      ZStack {
        palette.background.ignoresSafeArea()
        VStack(spacing: 0) {
          if !categories.isEmpty { categoryChips }
          content
        }
      }
      .navigationTitle("tency")
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button("Add habit", systemImage: "plus") { showingAdd = true }
        }
      }
      .sheet(isPresented: $showingAdd) { AddHabitView() }
      .navigationDestination(for: Habit.self) { HabitDetailView(habit: $0) }
      .onChange(of: habits.count) { navigateToTappedHabit() }
      .onChange(of: notificationRouter.tappedHabitID) { navigateToTappedHabit() }
      .task {
        WidgetSnapshot.write(context: context)
        navigateToTappedHabit()
      }
    }
  }

  private func navigateToTappedHabit() {
    guard let id = notificationRouter.tappedHabitID,
      let habit = habits.first(where: { $0.id == id })
    else { return }
    path = [habit]
    notificationRouter.tappedHabitID = nil
  }

  @ViewBuilder private var content: some View {
    if activeHabits.isEmpty {
      EmptyHabitsView { showingAdd = true }
    } else if filteredHabits.isEmpty {
      ContentUnavailableView(
        "Nothing here", systemImage: "tray",
        description: Text("No habits in this category yet."))
    } else {
      ScrollView {
        LazyVStack(spacing: 12) {
          ForEach(filteredHabits) { habit in
            HabitCard(habit: habit)
          }
        }
        .padding(16)
      }
    }
  }

  private var categoryChips: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: 8) {
        chip(title: "All", color: palette.tint, selected: selectedCategoryID == nil) {
          selectedCategoryID = nil
        }
        ForEach(categories) { category in
          chip(
            title: category.name,
            color: palette.accent(category.colorKey),
            selected: selectedCategoryID == category.id
          ) {
            selectedCategoryID = category.id
          }
        }
      }
      .padding(.horizontal, 16)
      .padding(.vertical, 10)
    }
  }

  private func chip(title: String, color: Color, selected: Bool, action: @escaping () -> Void) -> some View {
    Button(action: action) {
      Text(title)
        .font(.subheadline.weight(.medium))
        .padding(.horizontal, 14)
        .padding(.vertical, 7)
        .background(selected ? color : palette.surface, in: .capsule)
        .foregroundStyle(selected ? .white : palette.textPrimary)
    }
    .buttonStyle(.plain)
  }
}

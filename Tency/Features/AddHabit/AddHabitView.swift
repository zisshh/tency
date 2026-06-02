import SwiftData
import SwiftUI

struct AddHabitView: View {
  @Environment(\.dismiss) private var dismiss
  @Environment(\.modelContext) private var context
  @Environment(\.palette) private var palette
  @Query private var allHabits: [Habit]
  @Query(sort: \HabitCategory.sortOrder, order: .forward) private var categories: [HabitCategory]

  @State private var name = ""
  @State private var icon = "star.fill"
  @State private var iconTouched = false
  @State private var colorKey = "blue"
  @State private var kind: HabitKind = .binary
  @State private var target = 1.0
  @State private var unit = ""
  @State private var categoryID: UUID?
  @State private var reminderOn = false
  @State private var reminderTime = AddHabitView.defaultReminderTime
  @State private var reminderDays = ReminderDays.everyDay

  private let editing: Habit?

  private static var defaultReminderTime: Date {
    Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()
  }

  init(habit: Habit? = nil) {
    editing = habit
    _name = State(initialValue: habit?.name ?? "")
    _icon = State(initialValue: habit?.icon ?? "star.fill")
    _iconTouched = State(initialValue: habit != nil)
    _colorKey = State(initialValue: habit?.colorKey ?? "blue")
    _kind = State(initialValue: habit?.kind ?? .binary)
    _target = State(initialValue: habit?.targetPerDay ?? 1)
    _unit = State(initialValue: habit?.unit ?? "")
    _categoryID = State(initialValue: habit?.category?.id)
    _reminderOn = State(initialValue: habit?.reminderTime != nil)
    _reminderTime = State(initialValue: habit?.reminderTime ?? AddHabitView.defaultReminderTime)
    let storedDays = habit?.reminderDays ?? 0
    _reminderDays = State(initialValue: storedDays == 0 ? ReminderDays.everyDay : storedDays)
    _allHabits = Query()
    _categories = Query(sort: \HabitCategory.sortOrder, order: .forward)
  }

  private var trimmedName: String { name.trimmingCharacters(in: .whitespacesAndNewlines) }
  private var canSave: Bool { !trimmedName.isEmpty }
  private var accent: Color { palette.accent(colorKey) }

  var body: some View {
    NavigationStack {
      Form {
        Section {
          HStack(spacing: 14) {
            ZStack {
              Circle().fill(accent.opacity(0.18))
              Image(systemName: icon).font(.title2).foregroundStyle(accent)
            }
            .frame(width: 52, height: 52)

            TextField("Habit name", text: $name)
              .font(.title3)
              .onChange(of: name) {
                if !iconTouched, let suggestion = SymbolSuggester.suggest(for: name) {
                  icon = suggestion
                }
              }
          }
        }
        .listRowBackground(palette.surface)

        Section("Color") { colorPicker }
          .listRowBackground(palette.surface)
        Section("Icon") { iconPicker }
          .listRowBackground(palette.surface)

        Section("Type") {
          Picker("Type", selection: $kind) {
            ForEach(HabitKind.allCases) { Text($0.label).tag($0) }
          }
          .pickerStyle(.segmented)

          if kind == .amount {
            Stepper(value: $target, in: 1...1000, step: 1) {
              Text("Target: \(target.clean)\(unit.isEmpty ? "" : " \(unit)")")
            }
            TextField("Unit (min, ml, pages…)", text: $unit)
              .textInputAutocapitalization(.never)
              .autocorrectionDisabled()
          }
        }
        .listRowBackground(palette.surface)

        if !categories.isEmpty {
          Section("Category") {
            Picker("Category", selection: $categoryID) {
              Text("None").tag(UUID?.none)
              ForEach(categories) { category in
                Text(category.name).tag(Optional(category.id))
              }
            }
          }
          .listRowBackground(palette.surface)
        }

        Section("Reminder") {
          Toggle("Remind me", isOn: $reminderOn)
            .onChange(of: reminderOn) {
              if reminderOn { Task { _ = await NotificationService.requestAuthorization() } }
            }
          if reminderOn {
            DatePicker("Time", selection: $reminderTime, displayedComponents: .hourAndMinute)
            dayPicker
          }
        }
        .listRowBackground(palette.surface)
      }
      .scrollContentBackground(.hidden)
      .background(palette.background.ignoresSafeArea())
      .foregroundStyle(palette.textPrimary)
      .navigationTitle(editing == nil ? "New habit" : "Edit habit")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel") { dismiss() }
        }
        ToolbarItem(placement: .confirmationAction) {
          Button(editing == nil ? "Add" : "Save") { save() }
            .bold()
            .disabled(!canSave)
        }
      }
    }
  }

  private var colorPicker: some View {
    LazyVGrid(columns: [GridItem(.adaptive(minimum: 44), spacing: 12)], spacing: 12) {
      ForEach(palette.orderedAccents(), id: \.key) { entry in
        Button {
          colorKey = entry.key
        } label: {
          Circle()
            .fill(entry.color)
            .frame(width: 36, height: 36)
            .overlay {
              if entry.key == colorKey {
                Image(systemName: "checkmark")
                  .font(.caption.bold())
                  .foregroundStyle(.white)
              }
            }
            .overlay {
              Circle().strokeBorder(palette.textPrimary.opacity(entry.key == colorKey ? 0.5 : 0), lineWidth: 2)
            }
        }
        .buttonStyle(.plain)
      }
    }
    .padding(.vertical, 4)
  }

  private var iconPicker: some View {
    LazyVGrid(columns: [GridItem(.adaptive(minimum: 44), spacing: 12)], spacing: 12) {
      ForEach(SymbolSuggester.curated, id: \.self) { symbol in
        Button {
          icon = symbol
          iconTouched = true
        } label: {
          Image(systemName: symbol)
            .font(.title3)
            .frame(width: 40, height: 40)
            .foregroundStyle(icon == symbol ? accent : palette.textSecondary)
            .background(
              icon == symbol ? accent.opacity(0.18) : Color.clear,
              in: .rect(cornerRadius: 10))
        }
        .buttonStyle(.plain)
      }
    }
    .padding(.vertical, 4)
  }

  private var dayPicker: some View {
    HStack(spacing: 6) {
      ForEach(0..<7, id: \.self) { bit in
        let on = ReminderDays.isOn(bit, in: reminderDays)
        Button {
          reminderDays = ReminderDays.toggled(bit, in: reminderDays)
        } label: {
          Text(ReminderDays.symbols[bit])
            .font(.caption.weight(.semibold))
            .frame(width: 36, height: 36)
            .background(on ? accent : palette.surfaceElevated, in: .circle)
            .foregroundStyle(on ? .white : palette.textSecondary)
        }
        .buttonStyle(.plain)
      }
    }
    .frame(maxWidth: .infinity)
    .padding(.vertical, 2)
  }

  private func save() {
    let resolvedTarget = kind == .amount ? target : 1
    let resolvedUnit = kind == .amount && !unit.isEmpty ? unit : nil
    let category = categories.first { $0.id == categoryID }
    let habit: Habit
    if let existing = editing {
      habit = existing
      habit.name = trimmedName
      habit.icon = icon
      habit.colorKey = colorKey
      habit.kind = kind
      habit.targetPerDay = resolvedTarget
      habit.unit = resolvedUnit
    } else {
      habit = Habit(
        name: trimmedName,
        icon: icon,
        colorKey: colorKey,
        kind: kind,
        targetPerDay: resolvedTarget,
        unit: resolvedUnit,
        sortOrder: (allHabits.map(\.sortOrder).max() ?? 0) + 1)
      context.insert(habit)
    }
    habit.category = category
    habit.reminderTime = reminderOn ? reminderTime : nil
    habit.reminderDays = reminderDays
    try? context.save()
    WidgetSnapshot.write(context: context)
    NotificationService.reschedule(habit)
    dismiss()
  }
}

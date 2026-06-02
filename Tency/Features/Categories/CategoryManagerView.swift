import SwiftData
import SwiftUI

struct CategoryManagerView: View {
  @Environment(\.modelContext) private var context
  @Environment(\.palette) private var palette
  @Query(sort: \HabitCategory.sortOrder, order: .forward) private var categories: [HabitCategory]

  @State private var newName = ""
  @State private var newColor = "blue"

  private var canAdd: Bool { !newName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }

  var body: some View {
    Form {
      Section("New category") {
        TextField("Name", text: $newName)
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 40), spacing: 12)], spacing: 12) {
          ForEach(palette.orderedAccents(), id: \.key) { entry in
            Button { newColor = entry.key } label: {
              Circle()
                .fill(entry.color)
                .frame(width: 32, height: 32)
                .overlay {
                  Circle().strokeBorder(palette.textPrimary.opacity(entry.key == newColor ? 0.6 : 0), lineWidth: 2)
                }
            }
            .buttonStyle(.plain)
          }
        }
        .padding(.vertical, 4)
        Button("Add category") { add() }.disabled(!canAdd)
      }
      .listRowBackground(palette.surface)

      Section("Categories") {
        if categories.isEmpty {
          Text("No categories yet.").foregroundStyle(palette.textSecondary)
        } else {
          ForEach(categories) { category in
            HStack(spacing: 12) {
              Circle().fill(palette.accent(category.colorKey)).frame(width: 14, height: 14)
              Text(category.name)
              Spacer()
              Text("\(category.habits.count)").foregroundStyle(palette.textSecondary)
            }
          }
          .onDelete(perform: delete)
        }
      }
      .listRowBackground(palette.surface)
    }
    .scrollContentBackground(.hidden)
    .background(palette.background.ignoresSafeArea())
    .foregroundStyle(palette.textPrimary)
    .navigationTitle("Categories")
  }

  private func add() {
    let category = HabitCategory(
      name: newName.trimmingCharacters(in: .whitespacesAndNewlines),
      colorKey: newColor,
      sortOrder: (categories.map(\.sortOrder).max() ?? 0) + 1)
    context.insert(category)
    try? context.save()
    newName = ""
  }

  private func delete(_ offsets: IndexSet) {
    for index in offsets { context.delete(categories[index]) }
    try? context.save()
  }
}

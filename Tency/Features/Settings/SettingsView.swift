import SwiftData
import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
  @Environment(ThemeManager.self) private var themeManager
  @Environment(\.palette) private var palette
  @Environment(\.colorScheme) private var systemScheme
  @Query(sort: \Habit.sortOrder, order: .forward) private var habits: [Habit]
  @Query(sort: \HabitCategory.sortOrder, order: .forward) private var categories: [HabitCategory]

  @State private var exportDocument: BackupDocument?
  @State private var isExporting = false
  @State private var exportError: String?

  private var previewScheme: ColorScheme {
    switch themeManager.appearance {
    case .system: systemScheme
    case .light: .light
    case .dark: .dark
    }
  }

  var body: some View {
    @Bindable var theme = themeManager

    NavigationStack {
      Form {
        Section("Theme") {
          ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
              ForEach(ThemeCatalog.all) { item in
                Button {
                  theme.themeID = item.id
                } label: {
                  ThemePreviewCard(theme: item, scheme: previewScheme, selected: theme.themeID == item.id)
                }
                .buttonStyle(.plain)
              }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
          }
          .listRowInsets(EdgeInsets())
          .listRowBackground(Color.clear)
        }

        Section("Appearance") {
          Picker("Appearance", selection: $theme.appearance) {
            ForEach(Appearance.allCases) { Text($0.label).tag($0) }
          }
          .pickerStyle(.segmented)
        }
        .listRowBackground(palette.surface)

        Section("Calendar") {
          Toggle("Week starts Monday", isOn: $theme.weekStartsMonday)
        }
        .listRowBackground(palette.surface)

        Section("Habits") {
          NavigationLink {
            CategoryManagerView()
          } label: {
            Label("Manage categories", systemImage: "folder")
          }
        }
        .listRowBackground(palette.surface)

        Section("Data") {
          Button {
            exportBackup()
          } label: {
            Label("Export backup", systemImage: "square.and.arrow.up")
          }
          Text("Saves all habits and check-ins as a JSON file to the Files app.")
            .font(.footnote)
            .foregroundStyle(palette.textSecondary)
        }
        .listRowBackground(palette.surface)

        Section("About") {
          LabeledContent("App", value: "tency")
          LabeledContent("Version", value: "0.1.0")
          Text("Show up. Color the grid.")
            .font(.footnote)
            .foregroundStyle(palette.textSecondary)
        }
        .listRowBackground(palette.surface)
      }
      .scrollContentBackground(.hidden)
      .background(palette.background.ignoresSafeArea())
      .foregroundStyle(palette.textPrimary)
      .navigationTitle("Settings")
      .fileExporter(
        isPresented: $isExporting,
        document: exportDocument,
        contentType: .json,
        defaultFilename: "tency-backup-\(Self.dateStamp)"
      ) { result in
        if case .failure(let error) = result { exportError = error.localizedDescription }
      }
      .alert(
        "Export failed",
        isPresented: Binding(get: { exportError != nil }, set: { if !$0 { exportError = nil } })
      ) {
        Button("OK", role: .cancel) {}
      } message: {
        Text(exportError ?? "")
      }
    }
  }

  private func exportBackup() {
    do {
      let data = try BackupService.exportData(habits: habits, categories: categories)
      exportDocument = BackupDocument(data: data)
      isExporting = true
    } catch {
      exportError = error.localizedDescription
    }
  }

  private static var dateStamp: String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.string(from: Date())
  }
}

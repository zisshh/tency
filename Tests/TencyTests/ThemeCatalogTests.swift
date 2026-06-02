import Testing

@testable import Tency

struct ThemeCatalogTests {
  @Test func everyThemeDefinesAllAccentKeys() {
    for theme in ThemeCatalog.all {
      for key in accentKeys {
        #expect(theme.light.accents[key] != nil, "\(theme.name) light missing \(key)")
        #expect(theme.dark.accents[key] != nil, "\(theme.name) dark missing \(key)")
      }
    }
  }

  @Test func tintKeyResolvesForEveryTheme() {
    for theme in ThemeCatalog.all {
      #expect(theme.light.accents[theme.light.tintKey] != nil)
      #expect(theme.dark.accents[theme.dark.tintKey] != nil)
    }
  }

  @Test func catalogCoversEveryThemeID() {
    #expect(ThemeCatalog.all.count == ThemeID.allCases.count)
  }
}

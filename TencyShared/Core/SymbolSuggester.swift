import Foundation

/// Suggests an SF Symbol from a habit's name, and offers a curated icon set.
enum SymbolSuggester {
  private static let map: [(keys: [String], symbol: String)] = [
    (["run", "jog", "sprint", "cardio"], "figure.run"),
    (["walk", "steps", "step"], "figure.walk"),
    (["gym", "lift", "weight", "strength", "workout", "exercise"], "figure.strengthtraining.traditional"),
    (["yoga", "stretch", "mobility"], "figure.yoga"),
    (["meditate", "meditation", "calm", "breath", "mindful"], "figure.mind.and.body"),
    (["read", "reading", "book"], "book.fill"),
    (["study", "learn", "school", "class"], "graduationcap.fill"),
    (["code", "program", "dev", "leetcode"], "curlybraces"),
    (["write", "journal", "diary", "blog"], "pencil.line"),
    (["water", "hydrate", "drink"], "drop.fill"),
    (["coffee", "tea"], "cup.and.saucer.fill"),
    (["food", "eat", "meal", "diet", "cook"], "fork.knife"),
    (["sleep", "bed", "rest"], "bed.double.fill"),
    (["wake", "morning", "alarm"], "sunrise.fill"),
    (["money", "save", "budget", "finance"], "dollarsign.circle.fill"),
    (["music", "guitar", "piano", "practice"], "music.note"),
    (["art", "draw", "paint", "sketch"], "paintpalette.fill"),
    (["clean", "tidy", "chore"], "sparkles"),
    (["pray", "faith", "gratitude", "grateful"], "hands.sparkles.fill"),
    (["pill", "meds", "medicine", "vitamin"], "pills.fill"),
    (["language", "spanish", "french", "duolingo"], "globe"),
    (["nature", "outdoor", "hike"], "leaf.fill"),
    (["photo", "camera"], "camera.fill"),
    (["game", "play"], "gamecontroller.fill"),
  ]

  /// Icons shown in the picker grid.
  static let curated: [String] = [
    "star.fill", "flame.fill", "drop.fill", "leaf.fill", "bolt.fill", "heart.fill",
    "book.fill", "pencil.line", "figure.run", "figure.walk", "figure.yoga",
    "figure.strengthtraining.traditional", "figure.mind.and.body", "bed.double.fill",
    "fork.knife", "cup.and.saucer.fill", "pills.fill", "music.note", "paintpalette.fill",
    "dollarsign.circle.fill", "graduationcap.fill", "globe", "sparkles", "sunrise.fill",
    "moon.fill", "brain.head.profile", "hands.sparkles.fill", "camera.fill",
    "curlybraces", "gamecontroller.fill", "cart.fill", "checkmark.seal.fill",
  ]

  /// Best-guess symbol for a name, or nil if nothing matches.
  static func suggest(for name: String) -> String? {
    let lower = name.lowercased()
    guard !lower.isEmpty else { return nil }
    for entry in map where entry.keys.contains(where: { lower.contains($0) }) {
      return entry.symbol
    }
    return nil
  }
}

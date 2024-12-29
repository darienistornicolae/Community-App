import Foundation

struct CountryAchievementModel: Identifiable, Equatable {
  let id = UUID()
  let country: Asset
  var isUnlocked: Bool
  var unlockedDate: Date?

  static func == (lhs: CountryAchievementModel, rhs: CountryAchievementModel) -> Bool {
    lhs.id == rhs.id
  }
}

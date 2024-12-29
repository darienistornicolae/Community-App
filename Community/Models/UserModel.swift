import Foundation
import SwiftUI

struct UserModel {
  var id: Int
  var name: String
  var email: String
  var nationality: Nationality
  var location: String
  var bio: String
  var profileImage: UIImage?
  var unlockedCountries: [CountryAchievementModel] = []
}

// MARK: Helpers
extension UserModel {
  func hasUnlockedCountry(_ country: Asset) -> Bool {
    unlockedCountries.contains { $0.country == country && $0.isUnlocked }
  }

  func getUnlockDate(for country: Asset) -> Date? {
    unlockedCountries.first { $0.country == country }?.unlockedDate
  }

  mutating func unlockCountry(_ country: Asset) {
    if !hasUnlockedCountry(country) {
      let achievement = CountryAchievementModel(
        country: country,
        isUnlocked: true,
        unlockedDate: Date()
      )
      unlockedCountries.append(achievement)
    }
  }

  static func initialUser() -> UserModel {
    UserModel(
      id: 1,
      name: "John Doe",
      email: "john.doe@example.com",
      nationality: .british,
      location: "London, United Kingdom",
      bio: "Explorer and traveler, passionate about discovering new cultures and meeting people from around the world. Always eager to learn about different traditions and share experiences.",
      profileImage: nil,
      unlockedCountries: []
    )
  }
}

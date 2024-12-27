import SwiftUI

@MainActor
class AchievementsViewModel: ObservableObject {
  @Published var user: UserModel
  @Published var allCountries: [CountryAchievement]

  var unlockedCount: Int {
    allCountries.filter { $0.isUnlocked }.count
  }

  var totalCount: Int {
    allCountries.count
  }

  var progressPercentage: Double {
    Double(unlockedCount) / Double(totalCount)
  }

  init(
    user: UserModel = UserModel(
      id: 1,
      name: "John Doe",
      email: "john@example.com",
      nationality: .american,
      location: "New York",
      bio: "Explorer"
    )
  ) {
    self.user = user
    self.allCountries = Asset.allCases.map { country in
      CountryAchievement(
        country: country,
        isUnlocked: user.hasUnlockedCountry(country),
        unlockedDate: user.getUnlockDate(for: country)
      )
    }

    unlockInitialCountries()
  }
}

// MARK: Private
private extension AchievementsViewModel {
  func unlockInitialCountries() {
    let initialCountries: [Asset] = [
      .albaniaFlag,
      .germanyFlag,
      .franceFlag,
      .italyFlag,
      .spainFlag
    ]
    initialCountries.forEach { unlockCountry($0) }
  }

  func unlockCountry(_ country: Asset) {
    user.unlockCountry(country)
    if let index = allCountries.firstIndex(where: { $0.country == country }) {
      allCountries[index].isUnlocked = true
      allCountries[index].unlockedDate = Date()
    }
  }
}
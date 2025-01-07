import SwiftUI
import FirebaseFirestore

@MainActor
class AchievementsViewModel: ObservableObject {
  @Published var user: UserModel
  @Published var allCountries: [CountryAchievementModel]
  private let userManager: FirestoreManager<UserModel>
  private let achievementsManager: FirestoreManager<CountryAchievementModel>

  var unlockedCount: Int {
    allCountries.filter { $0.isUnlockedBy(userId: user.id) }.count
  }

  var totalCount: Int {
    allCountries.count
  }

  var progressPercentage: Double {
    Double(unlockedCount) / Double(totalCount)
  }

  init(user: UserModel = .initialUser()) {
    self.user = user
    self.userManager = FirestoreManager(collection: "users")
    self.achievementsManager = FirestoreManager(collection: "achievements")
    self.allCountries = []
    
    Task {
      await loadData()
    }
  }

  func unlockCountry(_ country: Asset) async {
    if let index = allCountries.firstIndex(where: { $0.country == country }) {
      var achievement = allCountries[index]

      if achievement.isUnlockedBy(userId: user.id) {
        return
      }

      let unlockInfo = CountryAchievementModel.AchievementUnlockModel(userId: user.id)
      achievement.unlockedBy.append(unlockInfo)
      allCountries[index] = achievement

      do {
        try await achievementsManager.updateDocument(
          id: achievement.id,
          data: [
            "unlockedBy": FieldValue.arrayUnion([unlockInfo.toFirestore()])
          ]
        )

        if !user.achievementIds.contains(achievement.id) {
          user.achievementIds.append(achievement.id)
          try await userManager.updateDocument(id: user.id, data: [
            "achievementIds": user.achievementIds
          ])
        }
      } catch {
        print("Error updating achievement: \(error)")
      }
    }
  }

  func hasUnlockedCountry(_ country: Asset) -> Bool {
    allCountries.first { $0.country == country }?.isUnlockedBy(userId: user.id) ?? false
  }

  func getUnlockDate(for country: Asset) -> Date? {
    allCountries.first { $0.country == country }?.getUnlockInfo(for: user.id)?.unlockedDate.dateValue()
  }
}

private extension AchievementsViewModel {
  private func loadData() async {
    do {
      let loadedUser = try await userManager.getDocument(id: user.id)
      self.user = loadedUser

      await loadOrCreateAchievements()
    } catch FirestoreError.failedToFetch {
      try? await userManager.createDocument(id: user.id, data: user.toFirestore())
      
      await loadOrCreateAchievements()
    } catch {
      print("Error loading user: \(error)")
    }
  }
  
/*
 The following functions are mock up functions to create initial
 achievements for the user
*/
  private func loadOrCreateAchievements() async {
    do {
      let achievements = try await achievementsManager.fetch()

      if achievements.isEmpty {
        await createInitialAchievements()
      } else {
        self.allCountries = achievements
        if !user.achievementIds.contains(where: { $0.starts(with: "albania") }) {
          await unlockInitialCountries()
        }
      }
    } catch {
      print("Error loading achievements: \(error)")
    }
  }

  private func createInitialAchievements() async {
    self.allCountries = Asset.allCases.map { country in
      CountryAchievementModel(country: country)
    }

    do {
      for achievement in allCountries {
        try await achievementsManager.createDocument(id: achievement.id, data: achievement.toFirestore())
      }
      await unlockInitialCountries()
    } catch {
      print("Error creating achievements: \(error)")
    }
  }

  private func unlockInitialCountries() async {
    let initialCountries: [Asset] = [
      .albaniaFlag,
      .germanyFlag,
      .franceFlag,
      .italyFlag,
      .spainFlag
    ]
    
    for country in initialCountries {
      await unlockCountry(country)
    }

    user.achievementIds = initialCountries.map { $0.rawValue }
    try? await userManager.updateDocument(id: user.id, data: [
      "achievementIds": user.achievementIds
    ])
  }
}

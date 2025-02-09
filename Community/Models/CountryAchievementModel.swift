import Foundation
import FirebaseFirestore

struct AchievementUnlockModel {
  let userId: String
  let unlockedDate: Timestamp

  init(userId: String, unlockedDate: Timestamp = Timestamp()) {
    self.userId = userId
    self.unlockedDate = unlockedDate
  }

  static func fromFirestore(_ dict: [String: Any]) -> AchievementUnlockModel {
    AchievementUnlockModel(
      userId: dict["userId"] as? String ?? "",
      unlockedDate: dict["unlockedDate"] as? Timestamp ?? Timestamp()
    )
  }

  func toFirestore() -> [String: Any] {
    [
      "userId": userId,
      "unlockedDate": unlockedDate
    ]
  }
}

struct CountryAchievementModel: Identifiable, FirestoreConvertible {
  let id: String
  let country: Asset
  var unlockedBy: [AchievementUnlockModel]

  init(country: Asset, unlockedBy: [AchievementUnlockModel] = []) {
    self.id = country.rawValue
    self.country = country
    self.unlockedBy = unlockedBy
  }

  static func fromFirestore(_ dict: [String: Any]) -> CountryAchievementModel {
    let countryRawValue = dict["country"] as? String ?? ""
    let country = Asset(rawValue: countryRawValue) ?? .albaniaFlag
    
    let unlockedByArray = dict["unlockedBy"] as? [[String: Any]] ?? []
    let unlockedBy = unlockedByArray.map { AchievementUnlockModel.fromFirestore($0) }
    
    return CountryAchievementModel(
      country: country,
      unlockedBy: unlockedBy
    )
  }

  func toFirestore() -> [String: Any] {
    [
      "id": id,
      "country": country.rawValue,
      "unlockedBy": unlockedBy.map { $0.toFirestore() }
    ]
  }

  var isUnlocked: Bool {
    !unlockedBy.isEmpty
  }

  func isUnlockedBy(userId: String) -> Bool {
    unlockedBy.contains { $0.userId == userId }
  }

  func getUnlockInfo(for userId: String) -> AchievementUnlockModel? {
    unlockedBy.first { $0.userId == userId }
  }
}

import Foundation
import FirebaseFirestore

struct CountryAchievementModel: Identifiable, FirestoreConvertible {
  let id: String  // country.rawValue
  let country: Asset
  var unlockedBy: [UnlockInfo] // Array of unlock info

  struct UnlockInfo {
    let userId: String
    let unlockedDate: Timestamp
    
    init(userId: String, unlockedDate: Timestamp = Timestamp()) {
      self.userId = userId
      self.unlockedDate = unlockedDate
    }

    static func fromFirestore(_ dict: [String: Any]) -> UnlockInfo {
      UnlockInfo(
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

  init(country: Asset, unlockedBy: [UnlockInfo] = []) {
    self.id = country.rawValue
    self.country = country
    self.unlockedBy = unlockedBy
  }

  static func fromFirestore(_ dict: [String: Any]) -> CountryAchievementModel {
    let id = dict["id"] as? String ?? ""
    let countryRawValue = dict["country"] as? String ?? ""
    let country = Asset(rawValue: countryRawValue) ?? .albaniaFlag
    
    let unlockedByArray = dict["unlockedBy"] as? [[String: Any]] ?? []
    let unlockedBy = unlockedByArray.map { UnlockInfo.fromFirestore($0) }
    
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

  func getUnlockInfo(for userId: String) -> UnlockInfo? {
    unlockedBy.first { $0.userId == userId }
  }
}

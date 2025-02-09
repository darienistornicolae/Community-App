import Foundation
import SwiftUI

enum UserId: String {
  case user1 = "user_001"
  case user2 = "user_002"
  case user3 = "user_003"
  case user4 = "user_004"
  case user5 = "user_005"

  static var current: UserId = .user3
}

struct UserModel {
  let id: String
  var name: String
  var email: String
  var nationality: Nationality
  var location: String
  var bio: String
  var profileImageUrl: String?
  var achievementIds: [String]
  var points: Int
  var pointsHistory: [PointsTransaction]

  init(
    id: String = UserId.current.rawValue,
    name: String,
    email: String,
    nationality: Nationality,
    location: String,
    bio: String,
    profileImageUrl: String? = nil,
    achievementIds: [String] = [],
    points: Int = 0,
    pointsHistory: [PointsTransaction] = []
  ) {
    self.id = id
    self.name = name
    self.email = email
    self.nationality = nationality
    self.location = location
    self.bio = bio
    self.profileImageUrl = profileImageUrl
    self.achievementIds = achievementIds
    self.points = points
    self.pointsHistory = pointsHistory
  }

  static func initialUser() -> UserModel {
    UserModel(
      name: "John Doe",
      email: "john.doe@example.com",
      nationality: .british,
      location: "London, United Kingdom",
      bio: "Explorer and traveler, passionate about discovering new cultures and meeting people from around the world. Always eager to learn about different traditions and share experiences.",
      profileImageUrl: nil,
      points: 50,
      pointsHistory: [
        PointsTransaction(
          userId: UserId.current.rawValue,
          amount: 50,
          type: .initial,
          description: "Welcome bonus points",
          timestamp: Date()
        )
      ]
    )
  }
  
  func withProfileImageUrl(_ url: String?) -> UserModel {
    UserModel(
      id: id,
      name: name,
      email: email,
      nationality: nationality,
      location: location,
      bio: bio,
      profileImageUrl: url,
      achievementIds: achievementIds,
      points: points,
      pointsHistory: pointsHistory
    )
  }
}

// MARK: Firestore Convertible
extension UserModel: FirestoreConvertible {
  static func fromFirestore(_ dict: [String: Any]) -> UserModel {
    let pointsHistory = (dict["pointsHistory"] as? [[String: Any]] ?? []).map { 
      PointsTransaction.fromFirestore($0)
    }

    return UserModel(
      id: dict["id"] as? String ?? "",
      name: dict["name"] as? String ?? "",
      email: dict["email"] as? String ?? "",
      nationality: Nationality(rawValue: dict["nationality"] as? String ?? "") ?? .british,
      location: dict["location"] as? String ?? "",
      bio: dict["bio"] as? String ?? "",
      profileImageUrl: dict["profileImageUrl"] as? String,
      achievementIds: dict["achievementIds"] as? [String] ?? [],
      points: dict["points"] as? Int ?? 0,
      pointsHistory: pointsHistory
    )
  }

  func toFirestore() -> [String: Any] {
    var dict: [String: Any] = [
      "id": id,
      "name": name,
      "email": email,
      "nationality": nationality.rawValue,
      "location": location,
      "bio": bio,
      "achievementIds": achievementIds,
      "points": points,
      "pointsHistory": pointsHistory.map { $0.toFirestore() }
    ]
    
    if let profileImageUrl = profileImageUrl {
      dict["profileImageUrl"] = profileImageUrl
    }
    
    return dict
  }
}

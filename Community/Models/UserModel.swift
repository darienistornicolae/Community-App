import Foundation
import SwiftUI

enum UserId: String {
  case user1 = "user_001"
  case user2 = "user_002"
  case user3 = "user_003"
  case user4 = "user_004"
  case user5 = "user_005"

  static var current: UserId = .user1
}

struct UserModel {
  let id: String
  var name: String
  var email: String
  var nationality: Nationality
  var location: String
  var bio: String
  var profileImage: UIImage?
  var achievementIds: [String]

  init(
    id: String = UserId.current.rawValue,
    name: String,
    email: String,
    nationality: Nationality,
    location: String,
    bio: String,
    profileImage: UIImage?,
    achievementIds: [String] = []
  ) {
    self.id = id
    self.name = name
    self.email = email
    self.nationality = nationality
    self.location = location
    self.bio = bio
    self.profileImage = profileImage
    self.achievementIds = achievementIds
  }

  static func initialUser() -> UserModel {
    UserModel(
      name: "John Doe",
      email: "john.doe@example.com",
      nationality: .british,
      location: "London, United Kingdom",
      bio: "Explorer and traveler, passionate about discovering new cultures and meeting people from around the world. Always eager to learn about different traditions and share experiences.",
      profileImage: nil
    )
  }
}

// MARK: Firestore Convertible
extension UserModel: FirestoreConvertible {
  static func fromFirestore(_ dict: [String: Any]) -> UserModel {
    UserModel(
      id: dict["id"] as? String ?? "",
      name: dict["name"] as? String ?? "",
      email: dict["email"] as? String ?? "",
      nationality: Nationality(rawValue: dict["nationality"] as? String ?? "") ?? .british,
      location: dict["location"] as? String ?? "",
      bio: dict["bio"] as? String ?? "",
      profileImage: nil,
      achievementIds: dict["achievementIds"] as? [String] ?? []
    )
  }

  func toFirestore() -> [String: Any] {
    [
      "id": id,
      "name": name,
      "email": email,
      "nationality": nationality.rawValue,
      "location": location,
      "bio": bio,
      "achievementIds": achievementIds
    ]
  }

}

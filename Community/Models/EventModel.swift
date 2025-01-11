import Foundation
import FirebaseFirestore

struct EventModel: Identifiable {
  let id: String
  let userId: String
  let title: String
  let description: String
  let location: String
  let date: Date
  let createdAt: Date
  let price: Int
  let imageUrl: String?
  var participants: [String]
  var creator: UserModel?

  init(
    id: String = UUID().uuidString,
    userId: String,
    title: String,
    description: String,
    location: String,
    date: Date,
    price: Int,
    imageUrl: String? = nil,
    participants: [String] = [],
    createdAt: Date = Date(),
    creator: UserModel? = nil
  ) {
    self.id = id
    self.userId = userId
    self.title = title
    self.description = description
    self.location = location
    self.date = date
    self.price = price
    self.imageUrl = imageUrl
    self.participants = participants
    self.createdAt = createdAt
    self.creator = creator
  }
}

// MARK: - Firestore Convertible
extension EventModel: FirestoreConvertible {
  static func fromFirestore(_ dict: [String: Any]) -> EventModel {
    let creator = (dict["creator"] as? [String: Any]).map { UserModel.fromFirestore($0) }
    
    return EventModel(
      id: dict["id"] as? String ?? "",
      userId: dict["userId"] as? String ?? "",
      title: dict["title"] as? String ?? "",
      description: dict["description"] as? String ?? "",
      location: dict["location"] as? String ?? "",
      date: (dict["date"] as? Timestamp)?.dateValue() ?? Date(),
      price: dict["price"] as? Int ?? 0,
      imageUrl: dict["imageUrl"] as? String,
      participants: dict["participants"] as? [String] ?? [],
      createdAt: (dict["createdAt"] as? Timestamp)?.dateValue() ?? Date(),
      creator: creator
    )
  }

  func toFirestore() -> [String: Any] {
    var dict: [String: Any] = [
      "id": id,
      "userId": userId,
      "title": title,
      "description": description,
      "location": location,
      "date": Timestamp(date: date),
      "price": price,
      "participants": participants,
      "createdAt": Timestamp(date: createdAt)
    ]
    
    if let imageUrl = imageUrl {
      dict["imageUrl"] = imageUrl
    }
    
    if let creator = creator {
      dict["creator"] = creator.toFirestore()
    }
    
    return dict
  }
}

extension EventModel {
  var formattedDate: String {
    DateFormatter.eventTime.string(from: date)
  }

  var formattedParticipants: String {
    "\(participants.count) participants"
  }

  var hasEnded: Bool {
    date < Date()
  }

  func canJoin(userId: String) -> Bool {
    !hasEnded && !participants.contains(userId) && userId != self.userId
  }

  func isCreator(userId: String) -> Bool {
    self.userId == userId
  }

  func isParticipating(userId: String) -> Bool {
    participants.contains(userId)
  }
  
  // Helper method to create a new event with an updated image URL
  func withImageUrl(_ imageUrl: String?) -> EventModel {
    EventModel(
      id: id,
      userId: userId,
      title: title,
      description: description,
      location: location,
      date: date,
      price: price,
      imageUrl: imageUrl,
      participants: participants,
      createdAt: createdAt,
      creator: creator
    )
  }
}

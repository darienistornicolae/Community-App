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
  var participants: [String]

  init(
    id: String = UUID().uuidString,
    userId: String,
    title: String,
    description: String,
    location: String,
    date: Date,
    price: Int,
    participants: [String] = [],
    createdAt: Date = Date()
  ) {
    self.id = id
    self.userId = userId
    self.title = title
    self.description = description
    self.location = location
    self.date = date
    self.price = price
    self.participants = participants
    self.createdAt = createdAt
  }
}

// MARK: - Firestore Convertible
extension EventModel: FirestoreConvertible {
  static func fromFirestore(_ dict: [String: Any]) -> EventModel {
    EventModel(
      id: dict["id"] as? String ?? "",
      userId: dict["userId"] as? String ?? "",
      title: dict["title"] as? String ?? "",
      description: dict["description"] as? String ?? "",
      location: dict["location"] as? String ?? "",
      date: (dict["date"] as? Timestamp)?.dateValue() ?? Date(),
      price: dict["price"] as? Int ?? 0,
      participants: dict["participants"] as? [String] ?? [],
      createdAt: (dict["createdAt"] as? Timestamp)?.dateValue() ?? Date()
    )
  }

  func toFirestore() -> [String: Any] {
    [
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
  }
}

extension EventModel {
  var formattedDate: String {
    DateFormatter.eventTime.string(from: date)
  }

  var formattedParticipants: String {
    "\(participants.count) participants"
  }

  func canJoin(userId: String) -> Bool {
    !participants.contains(userId) && userId != self.userId
  }

  func isCreator(userId: String) -> Bool {
    self.userId == userId
  }

  func isParticipating(userId: String) -> Bool {
    participants.contains(userId)
  }
}

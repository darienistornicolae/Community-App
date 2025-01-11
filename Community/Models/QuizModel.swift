import Foundation
import FirebaseFirestore

struct QuizModel: Identifiable {
  let id: String
  let userId: String
  let question: String
  let answers: [String]
  let correctAnswerIndex: Int
  let createdAt: Date
  var participants: [String]
  let points: Int
  let achievementId: String?
  let imageUrl: String?
  
  init(
    id: String = UUID().uuidString,
    userId: String,
    question: String,
    answers: [String],
    correctAnswerIndex: Int,
    points: Int = 10,
    participants: [String] = [],
    achievementId: String? = nil,
    imageUrl: String? = nil,
    createdAt: Date = Date()
  ) {
    self.id = id
    self.userId = userId
    self.question = question
    self.answers = answers
    self.correctAnswerIndex = correctAnswerIndex
    self.points = points
    self.participants = participants
    self.achievementId = achievementId
    self.imageUrl = imageUrl
    self.createdAt = createdAt
  }
}

// MARK: - Firestore Convertible
extension QuizModel: FirestoreConvertible {
  static func fromFirestore(_ dict: [String: Any]) -> QuizModel {
    QuizModel(
      id: dict["id"] as? String ?? "",
      userId: dict["userId"] as? String ?? "",
      question: dict["question"] as? String ?? "",
      answers: dict["answers"] as? [String] ?? [],
      correctAnswerIndex: dict["correctAnswerIndex"] as? Int ?? 0,
      points: dict["points"] as? Int ?? 10,
      participants: dict["participants"] as? [String] ?? [],
      achievementId: dict["achievementId"] as? String,
      imageUrl: dict["imageUrl"] as? String,
      createdAt: (dict["createdAt"] as? Timestamp)?.dateValue() ?? Date()
    )
  }
  
  func toFirestore() -> [String: Any] {
    var data: [String: Any] = [
      "id": id,
      "userId": userId,
      "question": question,
      "answers": answers,
      "correctAnswerIndex": correctAnswerIndex,
      "points": points,
      "participants": participants,
      "createdAt": Timestamp(date: createdAt)
    ]
    
    if let achievementId = achievementId {
      data["achievementId"] = achievementId
    }
    
    if let imageUrl = imageUrl {
      data["imageUrl"] = imageUrl
    }
    
    return data
  }
}

extension QuizModel {
  // Helper method to create a new quiz with an updated image URL
  func withImageUrl(_ imageUrl: String?) -> QuizModel {
    QuizModel(
      id: id,
      userId: userId,
      question: question,
      answers: answers,
      correctAnswerIndex: correctAnswerIndex,
      points: points,
      participants: participants,
      achievementId: achievementId,
      imageUrl: imageUrl,
      createdAt: createdAt
    )
  }
}

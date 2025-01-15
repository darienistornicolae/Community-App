import Foundation
import FirebaseFirestore

struct QuestModel: Identifiable {
  let id: String
  let title: String
  let description: String
  let points: Int
  let startDate: Date
  let endDate: Date
  let requirement: QuestRequirement
  var participants: [String]
  let completedBy: [String]
  let progress: Int
  let userProgress: [String: Int]

  var isActive: Bool {
    let now = Date()
    return now >= startDate && now <= endDate
  }

  var hasEnded: Bool {
    Date() > endDate
  }

  var isCompleted: Bool {
    completedBy.contains(UserId.current.rawValue)
  }

  var currentUserProgress: Int {
    userProgress[UserId.current.rawValue] ?? 0
  }

  var progressPercentage: Double {
    guard let total = requirement.totalRequired else { return 0 }
    return min(Double(currentUserProgress) / Double(total), 1.0)
  }
}

enum QuestRequirement: Codable {
  case quizCompletion(count: Int)
  case eventParticipation(count: Int)
  case achievementCollection(count: Int)
  case pointsEarned(amount: Int)

  var description: String {
    switch self {
    case .quizCompletion(let count):
      return "Complete \(count) different quizzes"
    case .eventParticipation(let count):
      return "Participate in \(count) events"
    case .achievementCollection(let count):
      return "Collect \(count) country achievements"
    case .pointsEarned(let amount):
      return "Earn \(amount) points"
    }
  }

  var totalRequired: Int? {
    switch self {
    case .quizCompletion(let count): return count
    case .eventParticipation(let count): return count
    case .achievementCollection(let count): return count
    case .pointsEarned(let amount): return amount
    }
  }
}

// MARK: - Firestore Convertible
extension QuestModel: FirestoreConvertible {
  static func fromFirestore(_ dict: [String: Any]) -> QuestModel {
    let requirementDict = dict["requirement"] as? [String: Any] ?? [:]
    let requirementType = requirementDict["type"] as? String ?? ""
    let requirementValue = requirementDict["value"] as? Int ?? 0

    let requirement: QuestRequirement
    switch requirementType {
    case "quizCompletion":
      requirement = .quizCompletion(count: requirementValue)
    case "eventParticipation":
      requirement = .eventParticipation(count: requirementValue)
    case "achievementCollection":
      requirement = .achievementCollection(count: requirementValue)
    case "pointsEarned":
      requirement = .pointsEarned(amount: requirementValue)
    default:
      requirement = .quizCompletion(count: 0)
    }

    return QuestModel(
      id: dict["id"] as? String ?? "",
      title: dict["title"] as? String ?? "",
      description: dict["description"] as? String ?? "",
      points: dict["points"] as? Int ?? 0,
      startDate: (dict["startDate"] as? Timestamp)?.dateValue() ?? Date(),
      endDate: (dict["endDate"] as? Timestamp)?.dateValue() ?? Date(),
      requirement: requirement,
      participants: dict["participants"] as? [String] ?? [],
      completedBy: dict["completedBy"] as? [String] ?? [],
      progress: dict["progress"] as? Int ?? 0,
      userProgress: dict["userProgress"] as? [String: Int] ?? [:]
    )
  }

  func toFirestore() -> [String: Any] {
    var requirementDict: [String: Any] = [:]
    var requirementType = ""
    var requirementValue = 0

    switch requirement {
    case .quizCompletion(let count):
      requirementType = "quizCompletion"
      requirementValue = count
    case .eventParticipation(let count):
      requirementType = "eventParticipation"
      requirementValue = count
    case .achievementCollection(let count):
      requirementType = "achievementCollection"
      requirementValue = count
    case .pointsEarned(let amount):
      requirementType = "pointsEarned"
      requirementValue = amount
    }

    requirementDict["type"] = requirementType
    requirementDict["value"] = requirementValue

    return [
      "id": id,
      "title": title,
      "description": description,
      "points": points,
      "startDate": Timestamp(date: startDate),
      "endDate": Timestamp(date: endDate),
      "requirement": requirementDict,
      "participants": participants,
      "completedBy": completedBy,
      "progress": progress,
      "userProgress": userProgress
    ]
  }
} 

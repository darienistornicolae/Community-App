import Foundation
import FirebaseFirestore

enum PointsTransactionType: String {
  case initial = "initial"
  case achievement = "achievement"
  case engagement = "engagement"
  case purchase = "purchase"
  case reward = "reward"
  case other = "other"
}

struct PointsTransaction: FirestoreConvertible {
  let userId: String
  let amount: Int
  let type: PointsTransactionType
  let description: String
  let timestamp: Date

  static func fromFirestore(_ dict: [String: Any]) -> PointsTransaction {
    PointsTransaction(
      userId: dict["userId"] as? String ?? "",
      amount: dict["amount"] as? Int ?? 0,
      type: PointsTransactionType(rawValue: dict["type"] as? String ?? "") ?? .other,
      description: dict["description"] as? String ?? "",
      timestamp: (dict["timestamp"] as? Timestamp)?.dateValue() ?? Date()
    )
  }

  func toFirestore() -> [String: Any] {
    [
      "userId": userId,
      "amount": amount,
      "type": type.rawValue,
      "description": description,
      "timestamp": Timestamp(date: timestamp)
    ]
  }
}

// MARK: - Errors
enum PointsError: LocalizedError {
  case insufficientPoints

  var errorDescription: String? {
    switch self {
    case .insufficientPoints:
      return "Insufficient points balance"
    }
  }
}

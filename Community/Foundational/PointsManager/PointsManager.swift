import Foundation
import FirebaseFirestore

protocol PointsManagerProtocol {
  var currentPoints: Int { get }

  func setupInitialPoints(for userId: String) async throws
  func getCurrentBalance(for userId: String) async throws -> Int
  func addPoints(to userId: String, amount: Int, type: PointsTransactionType, description: String) async throws
  func spendPoints(from userId: String, amount: Int, type: PointsTransactionType, description: String) async throws
  func getTransactionHistory(for userId: String) async throws -> [PointsTransaction]
  func refreshPoints(for userId: String) async
}

@MainActor
class PointsManager: @preconcurrency PointsManagerProtocol, ObservableObject {
  static let shared = PointsManager()
  static let initialPoints = 50

  @Published private(set) var currentPoints: Int = 0
  private let userManager: FirestoreManager<UserModel>

  private init() {
    self.userManager = FirestoreManager(collection: "users")
  }

  func refreshPoints(for userId: String) async {
    do {
      currentPoints = try await getCurrentBalance(for: userId)
    } catch {
      print("Error refreshing points: \(error)")
    }
  }

  func setupInitialPoints(for userId: String) async throws {
    let transaction = PointsTransaction(
      userId: userId,
      amount: Self.initialPoints,
      type: .initial,
      description: "Welcome bonus points",
      timestamp: Date()
    )

    let updateData: [String: Any] = [
      "points": Self.initialPoints,
      "pointsHistory": [transaction.toFirestore()]
    ]

    try await userManager.updateDocument(id: userId, data: updateData)
    await refreshPoints(for: userId)
  }

  func getCurrentBalance(for userId: String) async throws -> Int {
    let user = try await userManager.getDocument(id: userId)
    return user.points
  }

  func addPoints(
    to userId: String,
    amount: Int,
    type: PointsTransactionType,
    description: String
  ) async throws {
    let user = try await userManager.getDocument(id: userId)
    let newPoints = user.points + amount

    let transaction = PointsTransaction(
      userId: userId,
      amount: amount,
      type: type,
      description: description,
      timestamp: Date()
    )

    var newHistory = user.pointsHistory
    newHistory.append(transaction)

    let updateData: [String: Any] = [
      "points": newPoints,
      "pointsHistory": newHistory.map { $0.toFirestore() }
    ]

    try await userManager.updateDocument(id: userId, data: updateData)
    await refreshPoints(for: userId)
  }

  func spendPoints(
    from userId: String,
    amount: Int,
    type: PointsTransactionType,
    description: String
  ) async throws {
    let user = try await userManager.getDocument(id: userId)
    guard user.points >= amount else {
      throw PointsError.insufficientPoints
    }

    let newPoints = user.points - amount

    let transaction = PointsTransaction(
      userId: userId,
      amount: -amount,
      type: type,
      description: description,
      timestamp: Date()
    )

    var newHistory = user.pointsHistory
    newHistory.append(transaction)

    let updateData: [String: Any] = [
      "points": newPoints,
      "pointsHistory": newHistory.map { $0.toFirestore() }
    ]

    try await userManager.updateDocument(id: userId, data: updateData)
    await refreshPoints(for: userId)
  }

  func getTransactionHistory(for userId: String) async throws -> [PointsTransaction] {
    let user = try await userManager.getDocument(id: userId)
    return user.pointsHistory.sorted { $0.timestamp > $1.timestamp }
  }
}

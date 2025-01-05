import Foundation
import FirebaseFirestore
import SwiftUI
import Combine

@MainActor
class UserManager: ObservableObject {
  @Published private(set) var currentUser: UserModel?
  private let firestoreManager = FirestoreManager<UserModel>(collection: "users")
  private var listenerTask: Task<Void, Never>?

  static let shared = UserManager()

  private init() {}

  func startListening(userId: String) {
    stopListening()

    listenerTask = Task { [weak self] in
      guard let self else { return }

      let stream = AsyncStream<DocumentSnapshot> { continuation in
        let listener = Firestore.firestore()
          .collection("users")
          .document(userId)
          .addSnapshotListener { snapshot, error in
            if let error = error {
              print("Error listening for user updates: \(error)")
              return
            }

            if let snapshot = snapshot {
              continuation.yield(snapshot)
            }
          }

        continuation.onTermination = { _ in
          listener.remove()
        }
      }

      for await snapshot in stream {
        guard let data = snapshot.data() else { continue }
        self.currentUser = UserModel.fromFirestore(data)
      }
    }
  }

  func stopListening() {
    listenerTask?.cancel()
    listenerTask = nil
  }

  func updateUser(_ user: UserModel) async throws {
    try await firestoreManager.updateDocument(id: user.id, data: user.toFirestore())
  }

  func createUser(_ user: UserModel) async throws {
    try await firestoreManager.createDocument(id: user.id, data: user.toFirestore())
    startListening(userId: user.id)
  }

  func getUser(userId: String) async throws -> UserModel {
    try await firestoreManager.getDocument(id: userId)
  }

  deinit {
    Task { @MainActor in
      stopListening()
    }
  }
}

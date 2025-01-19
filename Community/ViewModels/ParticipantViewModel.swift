import Foundation

@MainActor
class ParticipantViewModel: ObservableObject {
  @Published private(set) var user: UserModel
  @Published private(set) var isLoading = false
  @Published private(set) var error: Error?

  private let userManager: any FirestoreProtocol<UserModel>

  init(
    userId: String,
    userManager: any FirestoreProtocol<UserModel> = FirestoreManager(collection: "users")
  ) {
    self.user = UserModel.initialUser()
    self.userManager = userManager

    Task {
      await fetchUser(userId: userId)
    }
  }

  private func fetchUser(userId: String) async {
    isLoading = true
    defer { isLoading = false }

    do {
      user = try await userManager.getDocument(id: userId)
    } catch {
      self.error = error
      print("Error fetching user: \(error)")
    }
  }
} 

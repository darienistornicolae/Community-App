import Foundation

@MainActor
class ParticipantViewModel: ObservableObject {
  @Published private(set) var user: UserModel
  @Published private(set) var isLoading = false
  @Published private(set) var error: Error?
  
  private let userManager: FirestoreManager<UserModel>
  
  init(userId: String) {
    self.user = UserModel.initialUser()
    self.userManager = FirestoreManager(collection: "users")
    
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
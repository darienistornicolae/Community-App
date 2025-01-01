import Foundation
import PhotosUI
import SwiftUI

@MainActor
class ProfileViewModel: ObservableObject {
  @Published var user: UserModel
  @Published var showingSettings = false
  @Published var selectedItem: PhotosPickerItem? {
    didSet { Task { await loadImage() } }
  }

  private let userManager: FirestoreManager<UserModel>
  let posts = (1...12).map { "post\($0)" }

  init(user: UserModel = .initialUser()) {
    self.user = user
    self.userManager = FirestoreManager(collection: "users")
    Task {
      await loadUser()
    }
  }

  private func loadUser() async {
    do {
      let loadedUser = try await userManager.getDocument(id: user.id)
      user = loadedUser
    } catch FirestoreError.failedToFetch {
      try? await createUser()
    } catch {
      print("Error loading user: \(error)")
    }
  }

  private func createUser() async throws {
    let userData: [String: Any] = [
      "id": user.id,
      "name": user.name,
      "email": user.email,
      "nationality": user.nationality.rawValue,
      "location": user.location,
      "bio": user.bio,
      "achievementIds": user.achievementIds
    ]
    try await userManager.createDocument(id: user.id, data: userData)
  }

  func updateUser() async throws {
    let userData: [String: Any] = [
      "name": user.name,
      "email": user.email,
      "nationality": user.nationality.rawValue,
      "location": user.location,
      "bio": user.bio,
      "achievementIds": user.achievementIds
    ]
    try await userManager.updateDocument(id: user.id, data: userData)
  }

  private func loadImage() async {
    guard let item = selectedItem else { return }

    do {
      guard let data = try await item.loadTransferable(type: Data.self) else { return }
      guard let uiImage = UIImage(data: data) else { return }

      let image = uiImage
      updateProfileImage(image)
      try await updateUser()
    } catch {
      print("Error loading image: \(error)")
    }
  }

  private func updateProfileImage(_ image: UIImage) {
    user.profileImage = image
  }
}

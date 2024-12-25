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

  let posts = (1...12).map { "post\($0)" }

  init() {
    self.user = UserModel(
      id: 1,
      name: "John Doe",
      email: "john.doe@example.com",
      nationality: .american,
      location: "Breda, North Brabant",
      bio: "I'm a software developer passionate about creating meaningful applications. Love hiking and photography in my free time."
    )
  }

  private func loadImage() async {
    guard let item = selectedItem else { return }

    do {
      guard let data = try await item.loadTransferable(type: Data.self) else { return }
      guard let uiImage = UIImage(data: data) else { return }

      let image = uiImage
      updateProfileImage(image)
    } catch {
      print("Error loading image: \(error)")
    }
  }

  private func updateProfileImage(_ image: UIImage) {
    user.profileImage = image
  }
}

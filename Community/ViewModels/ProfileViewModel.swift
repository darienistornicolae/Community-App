import Foundation
import PhotosUI
import SwiftUI
import Combine

@MainActor
class ProfileViewModel: ObservableObject {
  @Published var user: UserModel
  @Published var showingSettings = false
  @Published private(set) var currentPoints: Int = 0
  @Published private(set) var pointsHistory: [PointsTransaction] = []
  @Published private(set) var isUploadingImage = false
  @Published var selectedPhoto: PhotosPickerItem? {
    didSet { Task { await uploadImage() } }
  }

  private let userManager: FirestoreManager<UserModel>
  private let pointsManager: PointsManagerProtocol
  private let storageManager: FirebaseImageStoarageProtocol
  private var cancellables = Set<AnyCancellable>()

  let posts = (1...12).map { "post\($0)" }

  init(
    user: UserModel = .initialUser(),
    pointsManager: PointsManagerProtocol? = nil,
    storageManager: FirebaseImageStoarageProtocol = FirebaseStorageManager()
  ) {
    self.user = user
    self.userManager = FirestoreManager(collection: "users")
    self.pointsManager = pointsManager ?? PointsManager.shared
    self.storageManager = storageManager

    setupPointsObserver()

    Task {
      await loadUser()
      await refreshPointsHistory()
      await self.pointsManager.refreshPoints(for: user.id)
    }
  }

  func updateUser() async throws {
    var userData: [String: Any] = [
      "name": user.name,
      "email": user.email,
      "nationality": user.nationality.rawValue,
      "location": user.location,
      "bio": user.bio,
      "achievementIds": user.achievementIds
    ]

    if let profileImageUrl = user.profileImageUrl {
      userData["profileImageUrl"] = profileImageUrl
    }

    try await userManager.updateDocument(id: user.id, data: userData)
  }

  private func uploadImage() async {
    isUploadingImage = true
    defer { isUploadingImage = false }

    do {
      guard let item = selectedPhoto,
            let data = try await item.loadTransferable(type: Data.self) else { return }

      let compressedData = storageManager.compressImageData(data, maxSizeKB: 500)
      let path = storageManager.generateImagePath(for: "profile_images")
      let imageUrl = try await storageManager.uploadData(compressedData, path: path)

      // If there's an existing profile image, delete it
      if let oldImagePath = user.profileImageUrl {
        try? await storageManager.deleteFile(at: oldImagePath)
      }

      user = user.withProfileImageUrl(imageUrl)
      try await updateUser()
    } catch {
      print("Error uploading image: \(error)")
    }
  }
}

// MARK: - Points Management
private extension ProfileViewModel {
  func setupPointsObserver() {
    guard let observableManager = pointsManager as? PointsManager else { return }

    observableManager.$currentPoints
      .receive(on: RunLoop.main)
      .assign(to: \.currentPoints, on: self)
      .store(in: &cancellables)

    observableManager.$currentPoints
      .receive(on: RunLoop.main)
      .sink { [weak self] _ in
        Task { [weak self] in
          await self?.refreshPointsHistory()
        }
      }
      .store(in: &cancellables)
  }

  func refreshPointsHistory() async {
    do {
      pointsHistory = try await pointsManager.getTransactionHistory(for: user.id)
    } catch {
      print("Error loading points history: \(error)")
    }
  }
}

// MARK: - User Management
private extension ProfileViewModel {
  func loadUser() async {
    do {
      let loadedUser = try await userManager.getDocument(id: user.id)
      user = loadedUser
    } catch FirestoreError.failedToFetch {
      try? await createUser()
    } catch {
      print("Error loading user: \(error)")
    }
  }

  func createUser() async throws {
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
    try await pointsManager.setupInitialPoints(for: user.id)
  }
}

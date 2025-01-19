import Foundation
import SwiftUI
import PhotosUI

@MainActor
class QuizCreationViewModel: ObservableObject {
  @Published var question: String = ""
  @Published var answers: [String] = ["", "", "", ""]
  @Published var correctAnswerIndex: Int = 0
  @Published var points: Int = 10
  @Published var errorMessage: String?
  @Published var showError: Bool = false
  @Published var selectedAchievement: Asset?
  @Published var imageUrl: String?
  @Published private(set) var availableAchievements: [Asset] = []
  @Published private(set) var isUploadingImage = false

  private let quizManager: any FirestoreProtocol<QuizModel>
  private let achievementsManager: any FirestoreProtocol<CountryAchievementModel>
  private let storageManager: FirebaseImageStoarageProtocol

  var isValid: Bool {
    !question.isEmpty &&
    answers.allSatisfy { !$0.isEmpty } &&
    correctAnswerIndex >= 0 &&
    correctAnswerIndex < answers.count &&
    !isUploadingImage
  }

  init(
    quizManager: any FirestoreProtocol<QuizModel> = FirestoreManager(collection: "quizzes"),
    achievementsManager: any FirestoreProtocol<CountryAchievementModel> = FirestoreManager(collection: "achievements"),
    storageManager: FirebaseImageStoarageProtocol = FirebaseStorageManager()
  ) {
    self.quizManager = quizManager
    self.achievementsManager = achievementsManager
    self.storageManager = storageManager

    Task {
      await loadAvailableAchievements()
    }
  }

  func uploadImage(_ item: PhotosPickerItem) async {
    isUploadingImage = true
    defer { isUploadingImage = false }

    do {
      guard let data = try await item.loadTransferable(type: Data.self) else {
        throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to load image data"])
      }

      let compressedData = storageManager.compressImageData(data, maxSizeKB: 500)
      let path = storageManager.generateImagePath(for: "quiz_images")
      imageUrl = try await storageManager.uploadData(compressedData, path: path)
    } catch {
      errorMessage = "Failed to upload image: \(error.localizedDescription)"
      showError = true
      print("Error uploading image: \(error)")
    }
  }

  func createQuiz() async {
    do {
      var quiz = QuizModel(
        userId: UserId.current.rawValue,
        question: question,
        answers: answers,
        correctAnswerIndex: correctAnswerIndex,
        points: points,
        achievementId: selectedAchievement?.rawValue
      )

      if let imageUrl = imageUrl {
        quiz = quiz.withImageUrl(imageUrl)
      }

      try await quizManager.createDocument(id: quiz.id, data: quiz.toFirestore())
    } catch {
      errorMessage = "Failed to create quiz: \(error.localizedDescription)"
      showError = true
      print("Error creating quiz: \(error)")
    }
  }

  private func loadAvailableAchievements() async {
    do {
      let achievements = try await achievementsManager.fetch()
      let unlockedAchievements = achievements.filter { $0.isUnlockedBy(userId: UserId.current.rawValue) }
      let unlockedCountries = Set(unlockedAchievements.map { $0.country })
      availableAchievements = Asset.allCases.filter { !unlockedCountries.contains($0) }
    } catch {
      print("Error loading achievements: \(error)")
    }
  }
}

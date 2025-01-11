import Foundation
import SwiftUI

@MainActor
class QuizCreationViewModel: ObservableObject {
  @Published var question: String = ""
  @Published var answers: [String] = ["", "", "", ""]
  @Published var correctAnswerIndex: Int = 0
  @Published var points: Int = 10
  @Published var errorMessage: String?
  @Published var showError: Bool = false
  @Published var selectedAchievement: Asset?
  @Published private(set) var availableAchievements: [Asset] = []
  
  private let quizManager: FirestoreManager<QuizModel>
  private let achievementsManager: FirestoreManager<CountryAchievementModel>
  
  var isValid: Bool {
    !question.isEmpty &&
    answers.allSatisfy { !$0.isEmpty } &&
    correctAnswerIndex >= 0 &&
    correctAnswerIndex < answers.count
  }
  
  init() {
    self.quizManager = FirestoreManager(collection: "quizzes")
    self.achievementsManager = FirestoreManager(collection: "achievements")
    
    Task {
      await loadAvailableAchievements()
    }
  }
  
  func createQuiz() async {
    do {
      let quiz = QuizModel(
        userId: UserId.current.rawValue,
        question: question,
        answers: answers,
        correctAnswerIndex: correctAnswerIndex,
        points: points,
        achievementId: selectedAchievement?.rawValue
      )
      
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

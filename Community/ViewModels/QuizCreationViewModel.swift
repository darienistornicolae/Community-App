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
  
  private let quizManager: FirestoreManager<QuizModel>
  
  var isValid: Bool {
    !question.isEmpty &&
    answers.allSatisfy { !$0.isEmpty } &&
    correctAnswerIndex >= 0 &&
    correctAnswerIndex < answers.count
  }
  
  init() {
    self.quizManager = FirestoreManager(collection: "quizzes")
  }
  
  func createQuiz() async {
    do {
      let quiz = QuizModel(
        userId: UserId.current.rawValue,
        question: question,
        answers: answers,
        correctAnswerIndex: correctAnswerIndex,
        points: points
      )
      
      try await quizManager.createDocument(id: quiz.id, data: quiz.toFirestore())
    } catch {
      errorMessage = "Failed to create quiz: \(error.localizedDescription)"
      showError = true
      print("Error creating quiz: \(error)")
    }
  }
}

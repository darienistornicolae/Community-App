import Foundation
import FirebaseFirestore

@MainActor
class QuizViewModel: ObservableObject {
  @Published private(set) var quiz: QuizModel?
  @Published var selectedAnswerIndex: Int?
  @Published private(set) var quizResult: Bool?

  private let eventId: String
  private let quizManager: FirestoreManager<QuizModel>
  private let pointsManager: PointsManagerProtocol

  init(eventId: String, pointsManager: PointsManagerProtocol = PointsManager.shared) {
    self.eventId = eventId
    self.quizManager = FirestoreManager(collection: "quizzes")
    self.pointsManager = pointsManager
  }

  func fetchQuiz() async {
    do {
      let quizzes = try await quizManager.fetch()
      quiz = quizzes.randomElement()
    } catch {
      print("Error fetching quiz: \(error)")
    }
  }

  func submitAnswer() {
    guard let selectedAnswerIndex = selectedAnswerIndex,
          let quiz = quiz else { return }
    
    let isCorrect = selectedAnswerIndex == quiz.correctAnswerIndex
    quizResult = isCorrect

    if isCorrect {
      Task {
        do {
          try await pointsManager.addPoints(
            to: UserId.current.rawValue,
            amount: quiz.points,
            type: .reward,
            description: "Correct quiz answer: \(quiz.question)"
          )
          var updatedQuiz = quiz
          updatedQuiz.participants.append(UserId.current.rawValue)
          try await quizManager.updateDocument(
            id: quiz.id,
            data: updatedQuiz.toFirestore()
          )
        } catch {
          print("Error awarding points: \(error)")
        }
      }
    }
  }

  func reset() {
    selectedAnswerIndex = nil
    quizResult = nil
  }
}

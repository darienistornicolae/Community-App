import Foundation
import FirebaseFirestore

@MainActor
class QuizViewModel: ObservableObject {
  @Published private(set) var quiz: QuizModel?
  @Published var selectedAnswerIndex: Int?
  @Published private(set) var quizResult: Bool?
  @Published private(set) var unlockedAchievement: Asset?

  private let eventId: String
  private let quizManager: FirestoreManager<QuizModel>
  private let pointsManager: PointsManagerProtocol
  private let achievementsManager: FirestoreManager<CountryAchievementModel>
  private let userManager: FirestoreManager<UserModel>

  init(eventId: String, pointsManager: PointsManagerProtocol = PointsManager.shared) {
    self.eventId = eventId
    self.quizManager = FirestoreManager(collection: "quizzes")
    self.pointsManager = pointsManager
    self.achievementsManager = FirestoreManager(collection: "achievements")
    self.userManager = FirestoreManager(collection: "users")
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
          // Award points
          try await pointsManager.addPoints(
            to: UserId.current.rawValue,
            amount: quiz.points,
            type: .reward,
            description: "Correct quiz answer: \(quiz.question)"
          )

          // Update quiz participants
          var updatedQuiz = quiz
          updatedQuiz.participants.append(UserId.current.rawValue)
          try await quizManager.updateDocument(
            id: quiz.id,
            data: updatedQuiz.toFirestore()
          )

          // Handle achievement if available
          if let achievementId = quiz.achievementId {
            // First, update the user's achievements
            let user = try await userManager.getDocument(id: UserId.current.rawValue)
            if !user.achievementIds.contains(achievementId) {
              var updatedUser = user
              updatedUser.achievementIds.append(achievementId)
              try await userManager.updateDocument(
                id: user.id,
                data: ["achievementIds": updatedUser.achievementIds]
              )
              
              // Then, update the achievement's unlockedBy list
              let achievement = try await achievementsManager.getDocument(id: achievementId)
              if !achievement.isUnlockedBy(userId: UserId.current.rawValue) {
                var updatedAchievement = achievement
                updatedAchievement.unlockedBy.append(
                  AchievementUnlockModel(userId: UserId.current.rawValue)
                )
                try await achievementsManager.updateDocument(
                  id: achievementId,
                  data: updatedAchievement.toFirestore()
                )
                unlockedAchievement = achievement.country
              }
            }
          }
        } catch {
          print("Error awarding points or achievement: \(error)")
        }
      }
    }
  }

  func reset() {
    selectedAnswerIndex = nil
    quizResult = nil
    unlockedAchievement = nil
  }
}

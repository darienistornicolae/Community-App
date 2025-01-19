import Foundation
import FirebaseFirestore

@MainActor
class QuizViewModel: ObservableObject {
  @Published private(set) var quiz: QuizModel?
  @Published var selectedAnswerIndex: Int?
  @Published private(set) var quizResult: Bool?
  @Published private(set) var unlockedAchievement: Asset?

  private let eventId: String
  private let quizManager: any FirestoreProtocol<QuizModel>
  private let pointsManager: PointsManagerProtocol
  private let achievementsManager: any FirestoreProtocol<CountryAchievementModel>
  private let userManager: any FirestoreProtocol<UserModel>

  init(
    eventId: String, 
    pointsManager: PointsManagerProtocol = PointsManager.shared,
    quizManager: any FirestoreProtocol<QuizModel> = FirestoreManager(collection: "quizzes"),
    achievementsManager: any FirestoreProtocol<CountryAchievementModel> = FirestoreManager(collection: "achievements"),
    userManager: any FirestoreProtocol<UserModel> = FirestoreManager(collection: "users")
  ) {
    self.eventId = eventId
    self.quizManager = quizManager
    self.pointsManager = pointsManager
    self.achievementsManager = achievementsManager
    self.userManager = userManager
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
        await handleCorrectAnswer(quiz)
      }
    }
  }

  func reset() {
    selectedAnswerIndex = nil
    quizResult = nil
    unlockedAchievement = nil
  }
}

// MARK: Private
private extension QuizViewModel {
  func handleCorrectAnswer(_ quiz: QuizModel) async {
    do {
      try await awardPoints(quiz)
      try await updateQuizParticipants(quiz)
      await QuestProgressManager.shared.handleQuizCompletion(quizId: quiz.id)

      if let achievementId = quiz.achievementId {
        try await handleAchievement(achievementId)
      }
    } catch {
      print("Error handling correct answer: \(error)")
    }
  }

  func awardPoints(_ quiz: QuizModel) async throws {
    try await pointsManager.addPoints(
      to: UserId.current.rawValue,
      amount: quiz.points,
      type: .reward,
      description: "Correct quiz answer: \(quiz.question)"
    )
  }

  func updateQuizParticipants(_ quiz: QuizModel) async throws {
    var updatedQuiz = quiz
    updatedQuiz.participants.append(UserId.current.rawValue)
    try await quizManager.updateDocument(
      id: quiz.id,
      data: updatedQuiz.toFirestore()
    )
  }

  func handleAchievement(_ achievementId: String) async throws {
    let user = try await userManager.getDocument(id: UserId.current.rawValue)
    if !user.achievementIds.contains(achievementId) {
      try await updateUserAchievements(user, achievementId)
      try await updateAchievementUnlocks(achievementId)
    }
  }

  func updateUserAchievements(_ user: UserModel, _ achievementId: String) async throws {
    var updatedUser = user
    updatedUser.achievementIds.append(achievementId)
    try await userManager.updateDocument(
      id: user.id,
      data: ["achievementIds": updatedUser.achievementIds]
    )
  }

  func updateAchievementUnlocks(_ achievementId: String) async throws {
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

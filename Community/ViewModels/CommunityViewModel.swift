import Foundation

@MainActor
class CommunityViewModel: ObservableObject {
  @Published private(set) var quests: [QuestModel] = []
  @Published private(set) var quizzes: [QuizModel] = []
  @Published private(set) var isLoading = false
  @Published var errorMessage: String?

  private let questManager: any FirestoreProtocol<QuestModel>
  private let quizManager: any FirestoreProtocol<QuizModel>

  init(
    questManager: any FirestoreProtocol<QuestModel> = FirestoreManager(collection: "quests"),
    quizManager: any FirestoreProtocol<QuizModel> = FirestoreManager(collection: "quizzes")
  ) {
    self.questManager = questManager
    self.quizManager = quizManager
  }

  var activeQuests: [QuestModel] {
    quests.filter { $0.isActive && !$0.isCompleted }
  }

  var completedQuests: [QuestModel] {
    quests.filter { $0.isCompleted }
  }

  func fetchData() async {
    isLoading = true
    defer { isLoading = false }

    do {
      async let questsTask = questManager.fetch()
      async let quizzesTask = quizManager.fetch()

      let (fetchedQuests, fetchedQuizzes) = try await (questsTask, quizzesTask)

      quests = fetchedQuests.sorted { $0.endDate > $1.endDate }
      quizzes = fetchedQuizzes.sorted { $0.createdAt > $1.createdAt }
    } catch {
      errorMessage = "Failed to load community data: \(error.localizedDescription)"
      print("Error fetching community data: \(error)")
    }
  }
}

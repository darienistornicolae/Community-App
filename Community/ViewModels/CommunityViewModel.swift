import Foundation

@MainActor
class CommunityViewModel: ObservableObject {
  @Published private(set) var quests: [QuestModel] = []
  @Published private(set) var quizzes: [QuizModel] = []
  @Published private(set) var isLoading = false
  @Published var errorMessage: String?

  private let questManager: FirestoreManager<QuestModel>
  private let quizManager: FirestoreManager<QuizModel>

  init() {
    self.questManager = FirestoreManager(collection: "quests")
    self.quizManager = FirestoreManager(collection: "quizzes")
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

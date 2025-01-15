import Foundation
import FirebaseFirestore

@MainActor
final class QuestProgressManager {
  static let shared = QuestProgressManager()
  private let questManager: FirestoreManager<QuestModel>

  private init() {
    self.questManager = FirestoreManager(collection: "quests")
  }

  func handleQuizCompletion(quizId: String) async {
    do {
      let quizManager = FirestoreManager<QuizModel>(collection: "quizzes")
      let quiz = try await quizManager.getDocument(id: quizId)

      guard quiz.participants.contains(UserId.current.rawValue) else {
        return
      }
      
      let quests = try await questManager.fetch()
      let quizQuests = quests.filter { quest in
        if case .quizCompletion = quest.requirement {
          return quest.isActive && !quest.isCompleted
        }
        return false
      }

      for quest in quizQuests {
        let currentQuest = try await questManager.getDocument(id: quest.id)
        let currentProgress = currentQuest.userProgress[UserId.current.rawValue] ?? 0

        if currentProgress < (quest.requirement.totalRequired ?? 0) {
          try await updateQuestProgress(quest: quest, amount: 1)
        }
      }

      if let achievementId = quiz.achievementId {
        await handleAchievementUnlock(achievementId: achievementId)
      }

      await handlePointsEarned(amount: quiz.points)
    } catch {
      print("Error updating quiz completion progress: \(error)")
    }
  }

  func handleEventParticipation(eventId: String) async {
    do {
      let eventManager = FirestoreManager<EventModel>(collection: "events")
      let event = try await eventManager.getDocument(id: eventId)

      guard event.participants.contains(UserId.current.rawValue) else {
        return
      }
      
      let quests = try await questManager.fetch()
      let eventQuests = quests.filter { quest in
        if case .eventParticipation = quest.requirement {
          return quest.isActive && !quest.isCompleted
        }
        return false
      }

      for quest in eventQuests {
        let currentQuest = try await questManager.getDocument(id: quest.id)
        let currentProgress = currentQuest.userProgress[UserId.current.rawValue] ?? 0

        if currentProgress < (quest.requirement.totalRequired ?? 0) {
          try await updateQuestProgress(quest: quest, amount: 1)
        }
      }
    } catch {
      print("Error updating event participation progress: \(error)")
    }
  }

  func handleAchievementUnlock(achievementId: String) async {
    do {
      let achievementManager = FirestoreManager<CountryAchievementModel>(collection: "achievements")
      let achievement = try await achievementManager.getDocument(id: achievementId)

      guard achievement.isUnlockedBy(userId: UserId.current.rawValue) else {
        return
      }
      
      let quests = try await questManager.fetch()
      let achievementQuests = quests.filter { quest in
        if case .achievementCollection = quest.requirement {
          return quest.isActive && !quest.isCompleted
        }
        return false
      }

      for quest in achievementQuests {
        let currentQuest = try await questManager.getDocument(id: quest.id)
        let currentProgress = currentQuest.userProgress[UserId.current.rawValue] ?? 0

        if currentProgress < (quest.requirement.totalRequired ?? 0) {
          try await updateQuestProgress(quest: quest, amount: 1)
        }
      }
    } catch {
      print("Error updating achievement collection progress: \(error)")
    }
  }

  func handlePointsEarned(amount: Int) async {
    do {
      let quests = try await questManager.fetch()
      let pointsQuests = quests.filter { quest in
        if case .pointsEarned = quest.requirement {
          return quest.isActive && !quest.isCompleted
        }
        return false
      }

      for quest in pointsQuests {
        try await updateQuestProgress(quest: quest, amount: amount)
      }
    } catch {
      print("Error updating points earned progress: \(error)")
    }
  }

  func initializeQuestProgress() async {
    do {
      let quests = try await questManager.fetch()
      
      // Initialize progress for each quest type
      await initializeQuizProgress(quests: quests)
      await initializeEventProgress(quests: quests)
      await initializeAchievementProgress(quests: quests)
      await initializePointsProgress(quests: quests)
    } catch {
      print("Error initializing quest progress: \(error)")
    }
  }

  func handleEventParticipationRemoval(eventId: String) async {
    do {
      let eventManager = FirestoreManager<EventModel>(collection: "events")
      let event = try await eventManager.getDocument(id: eventId)

      guard !event.participants.contains(UserId.current.rawValue) else {
        return
      }
      
      let quests = try await questManager.fetch()
      let eventQuests = quests.filter { quest in
        if case .eventParticipation = quest.requirement {
          return quest.isActive && !quest.isCompleted
        }
        return false
      }
      
      for quest in eventQuests {
        let currentQuest = try await questManager.getDocument(id: quest.id)
        var updatedUserProgress = currentQuest.userProgress

        if let currentProgress = updatedUserProgress[UserId.current.rawValue], currentProgress > 0 {
          updatedUserProgress[UserId.current.rawValue] = currentProgress - 1
          
          try await questManager.updateDocument(
            id: quest.id,
            data: ["userProgress": updatedUserProgress]
          )
        }
      }
    } catch {
      print("Error updating event participation removal: \(error)")
    }
  }
} 

// MARK: Private
private extension QuestProgressManager {
  func updateQuestProgress(quest: QuestModel, amount: Int = 1) async throws {
    let currentQuest = try await questManager.getDocument(id: quest.id)

    guard !currentQuest.completedBy.contains(UserId.current.rawValue) else {
      return
    }

    let (updatedUserProgress, newProgress) = calculateNewProgress(currentQuest: currentQuest, amount: amount)
    let updatedParticipants = updateParticipantsList(currentParticipants: currentQuest.participants)

    try await updateQuestDocument(
      questId: quest.id,
      userProgress: updatedUserProgress,
      participants: updatedParticipants
    )

    if let total = quest.requirement.totalRequired, newProgress >= total {
      try await handleQuestCompletion(quest: quest, currentQuest: currentQuest)
    }
  }

  func calculateNewProgress(currentQuest: QuestModel, amount: Int) -> ([String: Int], Int) {
    var updatedUserProgress = currentQuest.userProgress
    let currentProgress = updatedUserProgress[UserId.current.rawValue] ?? 0
    let newProgress = currentProgress + amount
    updatedUserProgress[UserId.current.rawValue] = newProgress
    return (updatedUserProgress, newProgress)
  }

  func updateParticipantsList(currentParticipants: [String]) -> [String] {
    var updatedParticipants = currentParticipants
    if !updatedParticipants.contains(UserId.current.rawValue) {
      updatedParticipants.append(UserId.current.rawValue)
    }
    return updatedParticipants
  }

  func updateQuestDocument(questId: String, userProgress: [String: Int], participants: [String]) async throws {
    let totalProgress = userProgress.values.reduce(0, +)
    
    try await questManager.updateDocument(
      id: questId,
      data: [
        "userProgress": userProgress,
        "participants": participants,
        "progress": totalProgress
      ]
    )
  }

  func handleQuestCompletion(quest: QuestModel, currentQuest: QuestModel) async throws {
    var completedBy = currentQuest.completedBy
    completedBy.append(UserId.current.rawValue)

    var updatedUserProgress = currentQuest.userProgress
    if let total = quest.requirement.totalRequired {
      updatedUserProgress[UserId.current.rawValue] = total
    }
    let totalProgress = updatedUserProgress.values.reduce(0, +)

    try await questManager.updateDocument(
      id: quest.id,
      data: [
        "completedBy": completedBy,
        "userProgress": updatedUserProgress,
        "progress": totalProgress
      ]
    )

    try await PointsManager.shared.addPoints(
      to: UserId.current.rawValue,
      amount: quest.points,
      type: .reward,
      description: "Completed quest: \(quest.title)"
    )
  }
  
  func initializeQuizProgress(quests: [QuestModel]) async {
    do {
      let quizManager = FirestoreManager<QuizModel>(collection: "quizzes")
      let quizzes = try await quizManager.fetch()

      let completedQuizzes = quizzes.filter { quiz in
        quiz.participants.contains(UserId.current.rawValue)
      }

      let quizQuests = quests.filter { quest in
        if case .quizCompletion = quest.requirement {
          return quest.isActive && !quest.isCompleted
        }
        return false
      }
      
      for quest in quizQuests {
        try await updateQuestProgress(quest: quest, amount: completedQuizzes.count)
      }
    } catch {
      print("Error initializing quiz progress: \(error)")
    }
  }
  
  func initializeEventProgress(quests: [QuestModel]) async {
    do {
      let eventManager = FirestoreManager<EventModel>(collection: "events")
      let events = try await eventManager.fetch()

      let participatedEvents = events.filter { event in
        event.participants.contains(UserId.current.rawValue)
      }

      let eventQuests = quests.filter { quest in
        if case .eventParticipation = quest.requirement {
          return quest.isActive && !quest.isCompleted
        }
        return false
      }
      
      for quest in eventQuests {
        try await questManager.updateDocument(
          id: quest.id,
          data: ["userProgress.\(UserId.current.rawValue)": 0]
        )

        if !participatedEvents.isEmpty {
          try await updateQuestProgress(quest: quest, amount: participatedEvents.count)
        }
      }
    } catch {
      print("Error initializing event progress: \(error)")
    }
  }
  
  func initializeAchievementProgress(quests: [QuestModel]) async {
    do {
      let achievementManager = FirestoreManager<CountryAchievementModel>(collection: "achievements")
      let achievements = try await achievementManager.fetch()

      let unlockedAchievements = achievements.filter { achievement in
        achievement.isUnlockedBy(userId: UserId.current.rawValue)
      }

      let achievementQuests = quests.filter { quest in
        if case .achievementCollection = quest.requirement {
          return quest.isActive && !quest.isCompleted
        }
        return false
      }

      for quest in achievementQuests {
        try await updateQuestProgress(quest: quest, amount: unlockedAchievements.count)
      }
    } catch {
      print("Error initializing achievement progress: \(error)")
    }
  }
  
  func initializePointsProgress(quests: [QuestModel]) async {
    do {
      let totalPoints = await PointsManager.shared.getTotalPoints(for: UserId.current.rawValue)

      let pointsQuests = quests.filter { quest in
        if case .pointsEarned = quest.requirement {
          return quest.isActive && !quest.isCompleted
        }
        return false
      }

      for quest in pointsQuests {
        try await updateQuestProgress(quest: quest, amount: totalPoints)
      }
    } catch {
      print("Error initializing points progress: \(error)")
    }
  }
}

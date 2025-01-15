import Foundation
import FirebaseFirestore

struct PublishInitialQuests {
  static func publish() async {
    let quests: [[String: Any]] = [
      [
        "id": "weekly-quiz-champion",
        "title": "Weekly Quiz Champion",
        "description": "Challenge yourself to complete multiple quizzes this week and earn bonus points!",
        "points": 100,
        "startDate": Timestamp(date: Date()),
        "endDate": Timestamp(date: Calendar.current.date(byAdding: .day, value: 7, to: Date())!),
        "requirement": [
          "type": "quizCompletion",
          "value": 10
        ],
        "participants": [],
        "completedBy": [],
        "progress": 0,
        "userProgress": [:] as [String: Int]
      ],

      [
        "id": "event-explorer",
        "title": "Event Explorer",
        "description": "Participate in various community events and become an active member!",
        "points": 150,
        "startDate": Timestamp(date: Date()),
        "endDate": Timestamp(date: Calendar.current.date(byAdding: .day, value: 14, to: Date())!),
        "requirement": [
          "type": "eventParticipation",
          "value": 5
        ],
        "participants": [],
        "completedBy": [],
        "progress": 0,
        "userProgress": [:] as [String: Int]
      ],

      [
        "id": "flag-collector",
        "title": "Flag Collector",
        "description": "Collect country flags by completing quizzes and showcase your achievements!",
        "points": 200,
        "startDate": Timestamp(date: Date()),
        "endDate": Timestamp(date: Calendar.current.date(byAdding: .day, value: 30, to: Date())!),
        "requirement": [
          "type": "achievementCollection",
          "value": 8
        ],
        "participants": [],
        "completedBy": [],
        "progress": 0,
        "userProgress": [:] as [String: Int]
      ],

      [
        "id": "points-hunter",
        "title": "Points Hunter",
        "description": "Earn points through various activities and climb the leaderboard!",
        "points": 300,
        "startDate": Timestamp(date: Date()),
        "endDate": Timestamp(date: Calendar.current.date(byAdding: .day, value: 30, to: Date())!),
        "requirement": [
          "type": "pointsEarned",
          "value": 1000
        ],
        "participants": [],
        "completedBy": [],
        "progress": 0,
        "userProgress": [:] as [String: Int]
      ],

      [
        "id": "quick-learner",
        "title": "Quick Learner",
        "description": "Complete a series of quizzes in a short time to prove your knowledge!",
        "points": 75,
        "startDate": Timestamp(date: Date()),
        "endDate": Timestamp(date: Calendar.current.date(byAdding: .day, value: 3, to: Date())!),
        "requirement": [
          "type": "quizCompletion",
          "value": 5
        ],
        "participants": [],
        "completedBy": [],
        "progress": 0,
        "userProgress": [:] as [String: Int]
      ]
    ]
    
    let database = Firestore.firestore()
    let batch = database.batch()

    let questsRef = database.collection("quests")
    let existingQuests = try? await questsRef.getDocuments()
    if let existingQuests = existingQuests {
      for document in existingQuests.documents {
        batch.deleteDocument(document.reference)
      }
    }

    for quest in quests {
      let ref = questsRef.document(quest["id"] as! String)
      batch.setData(quest, forDocument: ref)
    }

    do {
      try await batch.commit()
      print("Successfully published initial quests!")
    } catch {
      print("Error publishing quests: \(error)")
    }
  }
} 

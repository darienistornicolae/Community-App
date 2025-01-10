import Foundation
import SwiftUI
import Combine
import FirebaseFirestore

@MainActor
class HomeViewModel: ObservableObject {
  @Published private(set) var currentPoints: Int = 0
  @Published private(set) var events: [EventModel] = []

  private let pointsManager: PointsManagerProtocol
  private let eventManager: FirestoreManager<EventModel>
  private let userId: String
  private var cancellables = Set<AnyCancellable>()
  private var eventsListener: ListenerRegistration?

  var currentUserId: String {
    userId
  }

  init(
    pointsManager: PointsManagerProtocol? = nil,
    userId: String = UserId.current.rawValue
  ) {
    self.pointsManager = pointsManager ?? PointsManager.shared
    self.eventManager = FirestoreManager(collection: "events")
    self.userId = userId

    setupPointsObserver()
    setupEventsListener()

    Task {
      await self.pointsManager.refreshPoints(for: userId)
    }
  }

  deinit {
    eventsListener?.remove()
  }

  func refresh() async {
    await pointsManager.refreshPoints(for: userId)

    do {
      let fetchedEvents = try await eventManager.fetch()
      events = fetchedEvents.sorted { $0.date > $1.date }
    } catch {
      print("Error refreshing events: \(error)")
    }
  }

  func joinEvent(_ event: EventModel) async {
    var updatedEvent = event
    updatedEvent.participants.append(userId)

    do {
      try await eventManager.updateDocument(
        id: event.id,
        data: ["participants": updatedEvent.participants]
      )
    } catch {
      print("Error joining event: \(error)")
    }
  }
}

// MARK: Private
private extension HomeViewModel {
  func setupPointsObserver() {
    guard let observableManager = pointsManager as? PointsManager else { return }

    observableManager.$currentPoints
      .receive(on: RunLoop.main)
      .assign(to: \.currentPoints, on: self)
      .store(in: &cancellables)
  }

  func setupEventsListener() {
    let db = Firestore.firestore()
    eventsListener = db.collection("events")
      .addSnapshotListener { [weak self] snapshot, error in
        guard let self = self else { return }
        
        if let error = error {
          print("Error listening for event updates: \(error)")
          return
        }
        
        guard let documents = snapshot?.documents else {
          print("No events found")
          return
        }
        
        self.events = documents.compactMap { document in
          var data = document.data()
          data["id"] = document.documentID
          return EventModel.fromFirestore(data)
        }.sorted { $0.date > $1.date }
      }
  }
}

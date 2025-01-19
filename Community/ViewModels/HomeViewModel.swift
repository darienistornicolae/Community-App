import Foundation
import SwiftUI
import Combine
import FirebaseFirestore

@MainActor
class HomeViewModel: ObservableObject {
  @Published private(set) var currentPoints: Int = 0
  @Published private(set) var events: [EventModel] = []

  private let pointsManager: PointsManagerProtocol
  private let eventManager: any FirestoreProtocol<EventModel>
  private let userId: String
  private var cancellables = Set<AnyCancellable>()
  private var eventsListener: ListenerRegistration?

  var currentUserId: String {
    userId
  }

  init(
    pointsManager: PointsManagerProtocol? = nil,
    eventManager: any FirestoreProtocol<EventModel> = FirestoreManager(collection: "events"),
    userId: String = UserId.current.rawValue
  ) {
    self.pointsManager = pointsManager ?? PointsManager.shared
    self.eventManager = eventManager
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
    eventsListener = eventManager.listen { [weak self] events in
      self?.events = events.sorted { $0.date > $1.date }
    }
  }
}

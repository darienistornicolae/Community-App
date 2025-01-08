import Foundation
import SwiftUI
import Combine

@MainActor
class HomeViewModel: ObservableObject {
  @Published private(set) var currentPoints: Int = 0
  @Published private(set) var events: [EventModel] = []

  private let pointsManager: PointsManagerProtocol
  private let eventManager: FirestoreManager<EventModel>
  private let userId: String
  private var cancellables = Set<AnyCancellable>()

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

    Task {
      await self.pointsManager.refreshPoints(for: userId)
      await fetchEvents()
    }
  }

  private func setupPointsObserver() {
    guard let observableManager = pointsManager as? PointsManager else { return }

    observableManager.$currentPoints
      .receive(on: RunLoop.main)
      .assign(to: \.currentPoints, on: self)
      .store(in: &cancellables)
  }

  func fetchEvents() async {
    do {
      let fetchedEvents = try await eventManager.fetch()
      events = fetchedEvents.sorted { $0.date > $1.date }
    } catch {
      print("Error fetching events: \(error)")
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
      await fetchEvents()
    } catch {
      print("Error joining event: \(error)")
    }
  }
}

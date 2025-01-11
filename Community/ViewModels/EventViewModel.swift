import Foundation
import SwiftUI

@MainActor
class EventViewModel: ObservableObject {
  @Published private(set) var event: EventModel
  @Published private(set) var isLoading = false
  @Published private(set) var error: Error?

  private let eventManager: FirestoreManager<EventModel>
  private let userManager: FirestoreManager<UserModel>

  init(event: EventModel) {
    self.event = event
    self.eventManager = FirestoreManager(collection: "events")
    self.userManager = FirestoreManager(collection: "users")

    Task {
      await fetchCreator()
    }
  }

  var status: EventStatus {
    switch (
      event.hasEnded,
      event.isCreator(userId: UserId.current.rawValue),
      event.isParticipating(userId: UserId.current.rawValue)
    ) {
    case (true, _, _):
      return .ended
    case (false, true, _):
      return .creator
    case (false, false, true):
      return .joined
    case (false, false, false):
      return .joinable(points: event.price)
    }
  }

  func fetchCreator() async {
    guard event.creator == nil else { return }

    isLoading = true
    defer { isLoading = false }

    do {
      let creator = try await userManager.getDocument(id: event.userId)
      event.creator = creator
    } catch {
      self.error = error
      print("Error fetching creator: \(error)")
    }
  }

  func joinEvent() async throws {
    var updatedEvent = event
    updatedEvent.participants.append(UserId.current.rawValue)
    try await eventManager.updateDocument(id: event.id, data: updatedEvent.toFirestore())
    event = updatedEvent
  }
} 

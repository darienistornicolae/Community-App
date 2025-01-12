import Foundation
import SwiftUI
import FirebaseFirestore

@MainActor
class EventViewModel: ObservableObject {
  @Published private(set) var event: EventModel
  @Published private(set) var isLoading = false
  @Published private(set) var error: Error?

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

  private let eventManager: FirestoreManager<EventModel>
  private let userManager: FirestoreManager<UserModel>
  private var creatorListener: ListenerRegistration?

  init(event: EventModel) {
    self.event = event
    self.eventManager = FirestoreManager(collection: "events")
    self.userManager = FirestoreManager(collection: "users")

    Task {
      await setupCreatorListener()
    }
  }

  deinit {
    creatorListener?.remove()
  }

  private func setupCreatorListener() async {
    creatorListener?.remove()

    creatorListener = userManager.listenToDocument(id: event.userId) { [weak self] updatedCreator in
      guard let self = self else { return }

      if let updatedCreator = updatedCreator {
        self.event.creator = updatedCreator
      } else {
        self.error = FirestoreError.failedToFetch
        print("Error: Creator document not found or error occurred")
      }
    }
  }

  func joinEvent() async throws {
    var updatedEvent = event
    updatedEvent.participants.append(UserId.current.rawValue)
    try await eventManager.updateDocument(id: event.id, data: updatedEvent.toFirestore())
    event = updatedEvent
  }
} 

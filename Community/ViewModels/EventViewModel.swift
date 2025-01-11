import Foundation

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
import Foundation

@MainActor
class ParticipantsViewModel: ObservableObject {
  @Published private(set) var participants: [UserModel] = []

  private let eventId: String
  private let eventManager: FirestoreManager<EventModel>
  private let userManager: FirestoreManager<UserModel>

  init(eventId: String) {
    self.eventId = eventId
    self.eventManager = FirestoreManager(collection: "events")
    self.userManager = FirestoreManager(collection: "users")
  }

  func fetchParticipants() async {
    do {
      let event = try await eventManager.getDocument(id: eventId)

      var participantUsers: [UserModel] = []
      for userId in event.participants {
        if let user = try? await userManager.getDocument(id: userId) {
          participantUsers.append(user)
        }
      }
      participants = participantUsers.sorted { $0.name < $1.name }
    } catch {
      print("Error fetching participants: \(error)")
    }
  }
}

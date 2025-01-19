import Foundation

@MainActor
class ParticipantsViewModel: ObservableObject {
  @Published private(set) var participants: [UserModel] = []

  private let eventId: String
  private let eventManager: any FirestoreProtocol<EventModel>
  private let userManager: any FirestoreProtocol<UserModel>

  init(
    eventId: String,
    eventManager: any FirestoreProtocol<EventModel> = FirestoreManager(collection: "events"),
    userManager: any FirestoreProtocol<UserModel> = FirestoreManager(collection: "users")
  ) {
    self.eventId = eventId
    self.eventManager = eventManager
    self.userManager = userManager
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

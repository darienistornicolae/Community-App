import Foundation
import SwiftUI

@MainActor
class EventCreationViewModel: ObservableObject {
  @Published var title: String = ""
  @Published var description: String = ""
  @Published var location: String = ""
  @Published var date: Date = Date()
  @Published var price: Int = 0

  private let eventManager: FirestoreManager<EventModel>

  var isValid: Bool {
    !title.isEmpty && !description.isEmpty && !location.isEmpty
  }

  init() {
    self.eventManager = FirestoreManager(collection: "events")
  }

  func createEvent() async {
    let event = EventModel(
      userId: UserId.current.rawValue,
      title: title,
      description: description,
      location: location,
      date: date,
      price: price
    )

    do {
      try await eventManager.createDocument(id: event.id, data: event.toFirestore())
    } catch {
      print("Error creating event: \(error)")
    }
  }
}

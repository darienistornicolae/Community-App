import Foundation
import SwiftUI
import PhotosUI

@MainActor
class EventCreationViewModel: ObservableObject {
  @Published var title: String = ""
  @Published var description: String = ""
  @Published var location: String = ""
  @Published var date: Date = Date()
  @Published var price: Int = 0
  @Published var imageUrl: String?
  @Published var errorMessage: String?
  @Published var showError: Bool = false
  @Published private(set) var isUploadingImage = false
  
  private let eventManager: FirestoreManager<EventModel>
  private let storageManager: FirebaseImageStoarageProtocol
  
  var isValid: Bool {
    !title.isEmpty &&
    !description.isEmpty &&
    !location.isEmpty &&
    date > Date() &&
    !isUploadingImage
  }
  
  init(storageManager: FirebaseImageStoarageProtocol = FirebaseStorageManager()) {
    self.eventManager = FirestoreManager(collection: "events")
    self.storageManager = storageManager
  }
  
  func uploadImage(_ item: PhotosPickerItem) async {
    isUploadingImage = true
    defer { isUploadingImage = false }
    
    do {
      guard let data = try await item.loadTransferable(type: Data.self) else {
        throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to load image data"])
      }
      
      let compressedData = storageManager.compressImageData(data, maxSizeKB: 500)
      let path = storageManager.generateImagePath(for: "event_images")
      imageUrl = try await storageManager.uploadData(compressedData, path: path)
    } catch {
      errorMessage = "Failed to upload image: \(error.localizedDescription)"
      showError = true
      print("Error uploading image: \(error)")
    }
  }
  
  func createEvent() async {
    do {
      var event = EventModel(
        userId: UserId.current.rawValue,
        title: title,
        description: description,
        location: location,
        date: date,
        price: price
      )
      
      if let imageUrl = imageUrl {
        event = event.withImageUrl(imageUrl)
      }
      
      try await eventManager.createDocument(id: event.id, data: event.toFirestore())
    } catch {
      errorMessage = "Failed to create event: \(error.localizedDescription)"
      showError = true
      print("Error creating event: \(error)")
    }
  }
}

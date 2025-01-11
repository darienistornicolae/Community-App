import Foundation
import FirebaseStorage
import UIKit

protocol FirebaseImageStoarageProtocol {
  func uploadData(_ data: Data, path: String) async throws -> String
  func deleteFile(at path: String) async throws
  func getDownloadURL(for path: String) async throws -> URL
  func generateImagePath(for folder: String) -> String
  func compressImageData(_ data: Data, maxSizeKB: Int) -> Data
}

class FirebaseStorageManager: FirebaseImageStoarageProtocol {
  private let storage = Storage.storage()

  func uploadData(_ data: Data, path: String) async throws -> String {
    let storageRef = storage.reference()
    let fileRef = storageRef.child(path)

    _ = try await fileRef.putDataAsync(data)
    let downloadURL = try await fileRef.downloadURL()
    return downloadURL.absoluteString
  }

  func deleteFile(at path: String) async throws {
    let storageRef = storage.reference()
    let fileRef = storageRef.child(path)
    try await fileRef.delete()
  }

  func getDownloadURL(for path: String) async throws -> URL {
    let storageRef = storage.reference()
    let fileRef = storageRef.child(path)
    return try await fileRef.downloadURL()
  }

  func generateImagePath(for folder: String = "images") -> String {
    let uuid = UUID().uuidString
    return "\(folder)/\(uuid).jpg"
  }

  func compressImageData(_ data: Data, maxSizeKB: Int = 500) -> Data {
    let maxSize = maxSizeKB * 1024

    if data.count <= maxSize {
      return data
    }

    var compression: CGFloat = 1.0
    var compressedData = data

    while compressedData.count > maxSize && compression > 0.1 {
      compression -= 0.1
      if let image = UIImage(data: data),
         let newData = image.jpegData(compressionQuality: compression) {
        compressedData = newData
      }
    }

    return compressedData
  }
} 

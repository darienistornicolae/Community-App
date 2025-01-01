import Foundation
import FirebaseFirestore
import SwiftUI

protocol FirestoreConvertible {
  static func fromFirestore(_ dict: [String: Any]) -> Self
  func toFirestore() -> [String: Any]
}

protocol FirestoreProtocol {
  associatedtype T: FirestoreConvertible
  var collection: String { get }
  func fetch() async throws -> [T]
  func upload(_ item: T) async throws
  func uploadMultiple(_ items: [T]) async throws
  func updateDocument(id: String, data: [String: Any]) async throws
  func getDocument(id: String) async throws -> T
  func createDocument(id: String, data: [String: Any]) async throws
}

enum FirestoreError: LocalizedError {
  case failedToFetch
  case failedToUpload
  case invalidData

  var errorDescription: String? {
    switch self {
    case .failedToFetch:
      return "Failed to fetch data from Firestore"
    case .failedToUpload:
      return "Failed to upload data to Firestore"
    case .invalidData:
      return "Invalid data structure"
    }
  }
}

final class FirestoreManager<T: FirestoreConvertible>: FirestoreProtocol {
  private let dataBase = Firestore.firestore()
  let collection: String

  init(collection: String) {
    self.collection = collection
  }

  func fetch() async throws -> [T] {
    try await withCheckedThrowingContinuation { continuation in
      dataBase.collection(collection)
        .getDocuments { snapshot, error in
          if let error = error {
            continuation.resume(throwing: error)
            return
          }

          guard let documents = snapshot?.documents else {
            continuation.resume(throwing: FirestoreError.failedToFetch)
            return
          }

          let items = documents.map { document in
            T.fromFirestore(document.data())
          }
          continuation.resume(returning: items)
        }
    }
  }

  func upload(_ item: T) async throws {
    try await dataBase.collection(collection).addDocument(data: item.toFirestore())
  }

  func uploadMultiple(_ items: [T]) async throws {
    try await withThrowingTaskGroup(of: Void.self) { group in
      for item in items {
        group.addTask {
          try await self.upload(item)
        }
      }
      try await group.waitForAll()
    }
  }

  func updateDocument(id: String, data: [String: Any]) async throws {
    do {
      try await dataBase.collection(collection).document(id).updateData(data)
    } catch {
      throw FirestoreError.failedToUpload
    }
  }

  func getDocument(id: String) async throws -> T {
    do {
      let document = try await dataBase.collection(collection).document(id).getDocument()
      
      guard let data = document.data() else {
        throw FirestoreError.invalidData
      }
      
      return T.fromFirestore(data)
    } catch {
      throw FirestoreError.failedToFetch
    }
  }

  func createDocument(id: String, data: [String: Any]) async throws {
    do {
      try await dataBase.collection(collection).document(id).setData(data)
    } catch {
      throw FirestoreError.failedToUpload
    }
  }
}

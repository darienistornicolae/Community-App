import SwiftUI

enum ImageLoadError: Error, Equatable {
  case networkError(String)
  case invalidResponse
  case invalidData
  case invalidURL
  case unknown
}

actor ImageCache {
  static let shared = ImageCache()

  private let cache = NSCache<NSString, UIImage>()
  private var loadingTasks: [String: Task<UIImage?, Error>] = [:]
  private let fileManager = FileManager.default
  private let cacheDirectory: URL
  private let urlSession: URLSession

  private init() {
    cache.countLimit = 100
    cache.totalCostLimit = 1024 * 1024 * 100

    let cachesDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
    cacheDirectory = cachesDirectory.appendingPathComponent("ImageCache")
    try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)

    let configuration = URLSessionConfiguration.default
    configuration.waitsForConnectivity = true
    configuration.timeoutIntervalForResource = 30
    configuration.timeoutIntervalForRequest = 15
    urlSession = URLSession(configuration: configuration)

    Task {
      await cleanOldCacheFiles()
    }
  }

  func get(from url: String) -> UIImage? {
    if let cachedImage = cache.object(forKey: url as NSString) {
      return cachedImage
    }

    let fileURL = diskCacheFileUrl(for: url)
    guard let data = try? Data(contentsOf: fileURL),
          let image = UIImage(data: data) else {
      return nil
    }

    cache.setObject(image, forKey: url as NSString)
    return image
  }

  func set(_ image: UIImage, for url: String) {
    cache.setObject(image, forKey: url as NSString)

    let fileURL = diskCacheFileUrl(for: url)
    guard let data = image.jpegData(compressionQuality: 0.8) else { return }
    try? data.write(to: fileURL)
  }

  func remove(for url: String) {
    cache.removeObject(forKey: url as NSString)
    let fileURL = diskCacheFileUrl(for: url)
    try? fileManager.removeItem(at: fileURL)
  }

  func loadImage(from urlString: String) async throws -> UIImage? {
    if let cachedImage = get(from: urlString) {
      return cachedImage
    }

    if let existingTask = loadingTasks[urlString] {
      return try await existingTask.value
    }

    let task = Task<UIImage?, Error> {
      guard let url = URL(string: urlString) else {
        throw ImageLoadError.invalidURL
      }

      for attempt in 0..<3 {
        do {
          let (data, response) = try await urlSession.data(from: url)

          guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
            throw ImageLoadError.invalidResponse
          }

          guard let image = UIImage(data: data) else {
            throw ImageLoadError.invalidData
          }

          set(image, for: urlString)
          return image

        } catch {
          if attempt == 2 {
            if let urlError = error as? URLError {
              switch urlError.code {
              case .notConnectedToInternet:
                throw ImageLoadError.networkError("No internet connection")
              case .networkConnectionLost:
                throw ImageLoadError.networkError("Connection lost")
              case .timedOut:
                throw ImageLoadError.networkError("Request timed out")
              default:
                throw ImageLoadError.networkError(urlError.localizedDescription)
              }
            }
            throw ImageLoadError.unknown
          }

          if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost, .timedOut:
              try? await Task.sleep(nanoseconds: UInt64(pow(2.0, Double(attempt))) * 1_000_000_000)
              continue
            default:
              throw ImageLoadError.networkError(urlError.localizedDescription)
            }
          }
          throw ImageLoadError.unknown
        }
      }
      throw ImageLoadError.networkError("Failed to load image after retries")
    }

    loadingTasks[urlString] = task

    defer { loadingTasks[urlString] = nil }

    return try await task.value
  }

  func clearCache() {
    cache.removeAllObjects()
    loadingTasks.values.forEach { $0.cancel() }
    loadingTasks.removeAll()

    try? fileManager.removeItem(at: cacheDirectory)
    try? fileManager.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
  }
}

private extension ImageCache {
  func cleanOldCacheFiles() {
    let thirtyDaysAgo = Date().addingTimeInterval(-30 * 24 * 60 * 60)

    guard let files = try? fileManager.contentsOfDirectory(
      at: cacheDirectory,
      includingPropertiesForKeys: [.creationDateKey]
    ) else {
      return
    }

    for file in files {
      guard let attributes = try? fileManager.attributesOfItem(atPath: file.path),
            let creationDate = attributes[.creationDate] as? Date,
            creationDate < thirtyDaysAgo else {
        continue
      }
      try? fileManager.removeItem(at: file)
    }
  }

  func diskCacheFileUrl(for key: String) -> URL {
    let fileName = key.replacingOccurrences(of: "/", with: "_")
      .replacingOccurrences(of: ":", with: "_")
    return cacheDirectory.appendingPathComponent(fileName)
  }
}

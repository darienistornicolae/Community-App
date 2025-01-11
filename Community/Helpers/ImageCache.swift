import SwiftUI

actor ImageCache {
  static let shared = ImageCache()
  
  private let cache = NSCache<NSString, UIImage>()
  private var loadingTasks: [String: Task<UIImage?, Error>] = [:]
  
  private init() {
    cache.countLimit = 100
    cache.totalCostLimit = 1024 * 1024 * 100
  }
  
  func get(from url: String) -> UIImage? {
    cache.object(forKey: url as NSString)
  }
  
  func set(_ image: UIImage, for url: String) {
    cache.setObject(image, forKey: url as NSString)
  }
  
  func remove(for url: String) {
    cache.removeObject(forKey: url as NSString)
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
        throw URLError(.badURL)
      }

      let (data, _) = try await URLSession.shared.data(from: url)
      guard let image = UIImage(data: data) else {
        throw URLError(.cannotDecodeContentData)
      }

      set(image, for: urlString)
      return image
    }
    
    loadingTasks[urlString] = task

    defer { loadingTasks[urlString] = nil }

    return try await task.value
  }

  func clearCache() {
    cache.removeAllObjects()
    loadingTasks.values.forEach { $0.cancel() }
    loadingTasks.removeAll()
  }
}

// MARK: - CachedAsyncImage View
struct CachedAsyncImage<Content: View, Placeholder: View>: View {
  private let url: String?
  private let scale: CGFloat
  private let content: (Image) -> Content
  private let placeholder: () -> Placeholder

  @State private var image: UIImage?
  @State private var isLoading = false
  @State private var error: Error?

  init(
    url: String?,
    scale: CGFloat = 1.0,
    @ViewBuilder content: @escaping (Image) -> Content,
    @ViewBuilder placeholder: @escaping () -> Placeholder
  ) {
    self.url = url
    self.scale = scale
    self.content = content
    self.placeholder = placeholder
  }

  var body: some View {
    Group {
      if let image = image {
        content(Image(uiImage: image))
      } else {
        placeholder()
      }
    }
    .task(id: url) {
      guard let urlString = url else { return }
      guard !isLoading else { return }

      isLoading = true
      defer { isLoading = false }

      do {
        image = try await ImageCache.shared.loadImage(from: urlString)
      } catch {
        self.error = error
        print("Error loading image: \(error)")
      }
    }
  }
}

// MARK: - Convenience Initializers
extension CachedAsyncImage where Content == Image {
  init(
    url: String?,
    scale: CGFloat = 1.0,
    @ViewBuilder placeholder: @escaping () -> Placeholder
  ) {
    self.init(url: url, scale: scale, content: { $0 }, placeholder: placeholder)
  }
}

extension CachedAsyncImage where Placeholder == ProgressView<EmptyView, EmptyView> {
  init(
    url: String?,
    scale: CGFloat = 1.0,
    @ViewBuilder content: @escaping (Image) -> Content
  ) {
    self.init(url: url, scale: scale, content: content) {
      ProgressView()
    }
  }
}

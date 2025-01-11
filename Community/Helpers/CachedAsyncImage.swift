import SwiftUI

struct CachedAsyncImage<Content: View, Placeholder: View>: View {
  private let url: String?
  private let scale: CGFloat
  private let content: (Image) -> Content
  private let placeholder: () -> Placeholder

  @State private var image: UIImage?
  @State private var isLoading = false
  @State private var error: ImageLoadError?
  @State private var retryCount = 0

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
      await loadImage()
    }
    .onChange(of: error) { newError in
      if newError != nil && retryCount < 3 {
        Task {
          try? await Task.sleep(nanoseconds: UInt64(pow(2.0, Double(retryCount))) * 1_000_000_000)
          retryCount += 1
          await loadImage()
        }
      }
    }
  }
  
  private func loadImage() async {
    guard let urlString = url else { return }
    guard !isLoading else { return }
    
    isLoading = true
    defer { isLoading = false }
    
    do {
      image = try await ImageCache.shared.loadImage(from: urlString)
      error = nil
    } catch let loadError as ImageLoadError {
      self.error = loadError
      print("Error loading image: \(loadError)")
    } catch {
      self.error = .unknown
      print("Unknown error loading image: \(error)")
    }
  }
}

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

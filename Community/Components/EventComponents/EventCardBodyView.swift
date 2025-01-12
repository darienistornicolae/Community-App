import SwiftUI

struct EventCardBodyView: View {
  let event: EventModel

  var body: some View {
    if let imageUrl = event.imageUrl {
      CachedAsyncImage(url: imageUrl) { image in
        image
          .resizable()
          .scaledToFill()
          .frame(maxWidth: .infinity)
          .frame(height: 300)
          .clipped()
          .opacity(event.hasEnded ? 0.6 : 1.0)
      } placeholder: {
        ProgressView()
          .frame(maxWidth: .infinity)
          .frame(height: 300)
      }
    } else {
      defaultEventBackground(event: event)
        .frame(height: 300)
    }
  }
}

// MARK: Private
private extension EventCardBodyView {
  func defaultEventBackground(event: EventModel) -> some View {
    LinearGradient(
      colors: event.hasEnded ?
      [Color.gray.opacity(0.7), Color.gray.opacity(0.7)] :
        [.blue.opacity(0.7), .purple.opacity(0.7)],
      startPoint: .topLeading,
      endPoint: .bottomTrailing
    )
    .overlay(
      VStack(spacing: Spacing.medium) {
        Text(event.title)
          .font(.title2)
          .bold()
          .multilineTextAlignment(.center)
          .foregroundColor(.white)

        Text(event.formattedDate)
          .font(.subheadline)
          .foregroundColor(.white.opacity(0.8))

        if event.hasEnded {
          Text("Event Ended")
            .font(.headline)
            .foregroundColor(.white)
            .padding(.horizontal, Spacing.default)
            .padding(.vertical, Spacing.small)
            .background(Color.black.opacity(0.6))
            .clipShape(Capsule())
        }
      }
        .padding(Spacing.default)
    )
  }
}

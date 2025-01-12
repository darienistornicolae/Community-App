import SwiftUI

struct EventCardHeaderView: View {
  let event: EventModel
  @Binding var presentationItem: EventItemsView?

  var body: some View {
    HStack(spacing: Spacing.small) {
      if let creator = event.creator, let imageUrl = creator.profileImageUrl {
        CachedAsyncImage(url: imageUrl) { image in
          image
            .resizable()
            .scaledToFill()
            .frame(width: 40, height: 40)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.gray.opacity(0.3), lineWidth: Spacing.halfPointSmall))
        } placeholder: {
          ProgressView()
            .frame(width: 40, height: 40)
        }
      } else {
        Circle()
          .fill(Color.gray.opacity(0.3))
          .frame(width: 40, height: 40)
          .overlay(
            Image(systemName: "person.crop.circle.fill")
              .resizable()
              .padding(Spacing.small)
              .foregroundColor(.gray)
          )
      }

      VStack(alignment: .leading, spacing: Spacing.extraSmall) {
        Text(event.creator?.name ?? event.userId)
          .font(.headline)
        Text(event.location)
          .font(.subheadline)
          .foregroundColor(.gray)
      }

      Spacer()

      Menu {
        ShareLink(item: shareMessage(event: event)) {
          Label("Share Event", systemImage: "square.and.arrow.up")
        }
        
        if event.isCreator(userId: UserId.current.rawValue) {
          Button {
            presentationItem = .participants
          } label: {
            Label("View Participants", systemImage: "person.2")
          }
        }
      } label: {
        Image(systemName: "ellipsis")
          .foregroundColor(.primary)
          .padding(Spacing.small)
      }
    }
    .padding(.horizontal, Spacing.default)
    .padding(.vertical, Spacing.medium)
  }
  private func shareMessage(event: EventModel) -> String {
    """
    Join me at \(event.title)!
    📍 \(event.location)
    📅 \(event.formattedDate)
    
    \(event.description)
    """
  }
}

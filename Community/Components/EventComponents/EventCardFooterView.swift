import SwiftUI

struct EventCardFooterView: View {
  let event: EventModel
  @Binding var isLiked: Bool
  @Binding var presentationItem: EventItemsView?
  let status: EventStatus
  
  var body: some View {
    HStack {
      Button {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
          isLiked.toggle()
        }
      } label: {
        Image(systemName: isLiked ? "heart.fill" : "heart")
          .font(.title2)
          .foregroundColor(isLiked ? .red : .primary)
          .symbolEffect(.bounce, value: isLiked)
      }
      .disabled(event.hasEnded)
      .opacity(event.hasEnded ? 0.6 : 1.0)

      Button {
        // Display the comments section. Probably in a future PR
      } label: {
        Image(systemName: "bubble.right")
          .font(.title2)
      }
      .disabled(event.hasEnded)
      .opacity(event.hasEnded ? 0.6 : 1.0)

      Spacer()

      EventStatusLabel(
        title: status.title,
        icon: status.icon,
        color: status.color,
        action: status.isJoinable ? { presentationItem = .quiz } : nil
      )
    }
    .padding(Spacing.small)
  }
}

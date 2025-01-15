import SwiftUI

enum EventItemsView: Identifiable {
  case participants
  case quiz

  var id: Self { self }
}

struct EventCardView: View {
  @StateObject private var viewModel: EventViewModel
  @EnvironmentObject private var pointsManager: PointsManager
  @State private var presentationItem: EventItemsView?
  @State private var showingPaymentAlert = false
  @State private var showingErrorAlert = false
  @State private var errorMessage = ""
  @State private var isLiked = false
  let currentUserId: String
  let onJoin: () -> Void

  init(event: EventModel, currentUserId: String, onJoin: @escaping () -> Void) {
    self._viewModel = StateObject(wrappedValue: EventViewModel(event: event))
    self.currentUserId = currentUserId
    self.onJoin = onJoin
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      EventCardHeaderView(event: viewModel.event, presentationItem: $presentationItem)
      EventCardBodyView(event: viewModel.event)

      EventCardFooterView(
        event: viewModel.event,
        isLiked: $isLiked,
        presentationItem: $presentationItem,
        status: viewModel.status
      )

      Divider()

      VStack(alignment: .leading, spacing: Spacing.small) {
        Text(viewModel.event.formattedParticipants)
          .font(.subheadline)
          .bold()

        Text(viewModel.event.description)
          .font(.subheadline)
          .lineLimit(3)

        Text(viewModel.event.formattedDate)
          .font(.caption)
          .foregroundColor(.gray)
          .padding(.top, Spacing.extraSmall)
      }
      .padding()
    }
    .background(Color(.systemBackground))
    .clipShape(RoundedRectangle(cornerRadius: Spacing.small))
    .overlay(
      RoundedRectangle(cornerRadius: Spacing.small)
        .stroke(Color.gray.opacity(0.1), lineWidth: Spacing.halfPointSmall)
    )
    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    .sheet(item: $presentationItem) { item in
      switch item {
      case .participants:
        ParticipantsView(viewModel: ParticipantsViewModel(eventId: viewModel.event.id))
          .presentationDetents([.medium])
      case .quiz:
        QuizView(eventId: viewModel.event.id) { success in
          if success {
            showingPaymentAlert = true
          }
        }
      }
    }
    .alert("Join Event", isPresented: $showingPaymentAlert) {
      Button("Cancel", role: .cancel) { }
      Button("Pay \(viewModel.event.price) Points") {
        Task {
          await joinEvent()
        }
      }
    } message: {
      Text("Would you like to join this event for \(viewModel.event.price) points?")
    }
    .alert("Error", isPresented: $showingErrorAlert) {
      Button("OK", role: .cancel) { }
    } message: {
      Text(errorMessage)
    }
  }
}

// MARK: - Private
private extension EventCardView {
  func joinEvent() async {
    do {
      try await pointsManager.spendPoints(
        from: currentUserId,
        amount: viewModel.event.price,
        type: .purchase,
        description: "Joined event: \(viewModel.event.title)"
      )
      try await viewModel.joinEvent()
      onJoin()
    } catch PointsError.insufficientPoints {
      errorMessage = "You don't have enough points to join this event"
      showingErrorAlert = true
    } catch {
      errorMessage = "Failed to join event"
      showingErrorAlert = true
    }
  }
}

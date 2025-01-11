import SwiftUI

private enum PresentationItem: Identifiable {
  case participants
  case quiz

  var id: Self { self }
}

struct EventCard: View {
  @StateObject private var viewModel: EventViewModel
  let currentUserId: String
  let onJoin: () -> Void
  @EnvironmentObject private var pointsManager: PointsManager
  @State private var presentationItem: PresentationItem?
  @State private var showingPaymentAlert = false
  @State private var showingErrorAlert = false
  @State private var errorMessage = ""
  @State private var isLiked = false

  init(event: EventModel, currentUserId: String, onJoin: @escaping () -> Void) {
    self._viewModel = StateObject(wrappedValue: EventViewModel(event: event))
    self.currentUserId = currentUserId
    self.onJoin = onJoin
  }

  private var shareMessage: String {
    """
    Join me at \(viewModel.event.title)!
    📍 \(viewModel.event.location)
    📅 \(viewModel.event.formattedDate)
    
    \(viewModel.event.description)
    """
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      HStack {
        if let creator = viewModel.event.creator, let imageUrl = creator.profileImageUrl {
          AsyncImage(url: URL(string: imageUrl)) { image in
            image
              .resizable()
              .scaledToFill()
              .frame(width: 40, height: 40)
              .clipShape(Circle())
              .overlay(Circle().stroke(Color.gray.opacity(0.2), lineWidth: 1))
          } placeholder: {
            ProgressView()
              .frame(width: 40, height: 40)
          }
        } else {
          Circle()
            .fill(Color.gray.opacity(0.2))
            .frame(width: 40, height: 40)
            .overlay(
              Image(systemName: "person.crop.circle.fill")
                .resizable()
                .padding(8)
                .foregroundColor(.gray)
            )
        }
        
        VStack(alignment: .leading, spacing: 2) {
          Text(viewModel.event.creator?.name ?? viewModel.event.userId)
            .font(.headline)
          Text(viewModel.event.location)
            .font(.subheadline)
            .foregroundColor(.gray)
        }
        .padding(.leading, Spacing.small)
        
        Spacer()
        
        Menu {
          ShareLink(item: shareMessage) {
            Label("Share Event", systemImage: "square.and.arrow.up")
          }
          
          if viewModel.event.isCreator(userId: currentUserId) {
            Button {
              presentationItem = .participants
            } label: {
              Label("View Participants", systemImage: "person.2")
            }
          }
        } label: {
          Image(systemName: "ellipsis")
            .foregroundColor(.primary)
            .padding(8)
        }
      }
      .padding(.horizontal)
      .padding(.vertical, Spacing.small)
      
      Divider()
        .padding(.horizontal)

      if let imageUrl = viewModel.event.imageUrl {
        AsyncImage(url: URL(string: imageUrl)) { image in
          image
            .resizable()
            .scaledToFill()
            .frame(maxWidth: .infinity)
            .frame(height: 250)
            .clipped()
            .opacity(viewModel.event.hasEnded ? 0.6 : 1.0)
        } placeholder: {
          defaultEventBackground
        }
      } else {
        defaultEventBackground
          .frame(height: 250)
      }
      
      Divider()
        .padding(.horizontal)

      HStack(spacing: Spacing.large) {
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
        .disabled(viewModel.event.hasEnded)
        .opacity(viewModel.event.hasEnded ? 0.6 : 1.0)
        
        Button {
          // Display the comments section. Probably in a future PR
        } label: {
          Image(systemName: "bubble.right")
            .font(.title2)
        }
        .disabled(viewModel.event.hasEnded)
        .opacity(viewModel.event.hasEnded ? 0.6 : 1.0)
        
        ShareLink(item: shareMessage) {
          Image(systemName: "paperplane")
            .font(.title2)
            .foregroundColor(.primary)
        }
        .opacity(viewModel.event.hasEnded ? 0.6 : 1.0)
        
        Spacer()
        
        if !viewModel.event.isCreator(userId: currentUserId) {
          if viewModel.event.isParticipating(userId: currentUserId) {
            if viewModel.event.hasEnded {
              Label("Event Ended", systemImage: "clock.fill")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.gray.opacity(0.2))
                .clipShape(Capsule())
            } else {
              Label("Joined", systemImage: "checkmark.circle.fill")
                .font(.subheadline)
                .foregroundColor(.green)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.green.opacity(0.2))
                .clipShape(Capsule())
            }
          } else {
            if viewModel.event.hasEnded {
              Label("Event Ended", systemImage: "clock.fill")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.gray.opacity(0.2))
                .clipShape(Capsule())
            } else {
              Button {
                presentationItem = .quiz
              } label: {
                Label("\(viewModel.event.price) Points", systemImage: "ticket.fill")
                  .font(.subheadline)
                  .foregroundColor(.white)
                  .padding(.horizontal, 12)
                  .padding(.vertical, 6)
                  .background(Color.blue)
                  .clipShape(Capsule())
              }
            }
          }
        } else {
          if viewModel.event.hasEnded {
            Label("Event Ended", systemImage: "clock.fill")
              .font(.subheadline)
              .foregroundColor(.gray)
              .padding(.horizontal, 12)
              .padding(.vertical, 6)
              .background(Color.gray.opacity(0.2))
              .clipShape(Capsule())
          } else {
            Label("Your Event", systemImage: "star.fill")
              .font(.subheadline)
              .foregroundColor(.orange)
              .padding(.horizontal, 12)
              .padding(.vertical, 6)
              .background(Color.orange.opacity(0.2))
              .clipShape(Capsule())
          }
        }
      }
      .padding()
      
      Divider()
        .padding(.horizontal)

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
          .padding(.top, 4)
      }
      .padding(.horizontal)
      .padding(.bottom)
    }
    .background(Color(.systemBackground))
    .clipShape(RoundedRectangle(cornerRadius: 12))
    .overlay(
      RoundedRectangle(cornerRadius: 12)
        .stroke(Color.gray.opacity(0.1), lineWidth: 1)
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

  private func joinEvent() async {
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

  private var defaultEventBackground: some View {
    LinearGradient(
      colors: viewModel.event.hasEnded ? 
        [Color.gray.opacity(0.7), Color.gray.opacity(0.7)] :
        [.blue.opacity(0.7), .purple.opacity(0.7)],
      startPoint: .topLeading,
      endPoint: .bottomTrailing
    )
    .overlay(
      VStack(spacing: Spacing.medium) {
        Text(viewModel.event.title)
          .font(.title2)
          .bold()
          .multilineTextAlignment(.center)
          .foregroundColor(.white)
        
        Text(viewModel.event.formattedDate)
          .font(.subheadline)
          .foregroundColor(.white.opacity(0.8))
        
        if viewModel.event.hasEnded {
          Text("Event Ended")
            .font(.headline)
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.black.opacity(0.6))
            .clipShape(Capsule())
        }
      }
      .padding()
    )
  }
}

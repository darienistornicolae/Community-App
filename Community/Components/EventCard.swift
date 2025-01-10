import SwiftUI

struct EventCard: View {
  let event: EventModel
  let currentUserId: String
  let onJoin: () -> Void
  @EnvironmentObject private var pointsManager: PointsManager
  @State private var showingPaymentAlert = false
  @State private var showingErrorAlert = false
  @State private var showingParticipants = false
  @State private var showingQuiz = false
  @State private var errorMessage = ""

  var body: some View {
    VStack(alignment: .leading, spacing: Spacing.medium) {
      VStack(alignment: .leading, spacing: Spacing.extraSmall) {
        Text(event.title)
          .font(.title2)
          .bold()

        Text("Hosted by \(event.userId)")
          .font(.subheadline)
          .foregroundColor(.gray)
      }

      Text(event.description)
        .font(.body)
        .lineLimit(3)

      HStack {
        Label(event.location, systemImage: "location.fill")
        Spacer()
        Label(event.formattedDate, systemImage: "calendar")
      }
      .font(.caption)
      .foregroundColor(.gray)

      HStack {
        if event.isCreator(userId: currentUserId) {
          Button {
            showingParticipants = true
          } label: {
            Label(event.formattedParticipants, systemImage: "person.2.fill")
              .font(.subheadline)
              .foregroundColor(.blue)
              .padding(.horizontal, Spacing.medium)
              .padding(.vertical, Spacing.small)
              .background(Color.blue.opacity(0.1))
              .cornerRadius(Spacing.small)
          }
        } else {
          Label(event.formattedParticipants, systemImage: "person.2.fill")
            .font(.caption)
            .foregroundColor(.gray)
        }

        Spacer()

        if !event.isCreator(userId: currentUserId) {
          if event.isParticipating(userId: currentUserId) {
            Text("Joined")
              .font(.headline)
              .foregroundColor(.green)
              .padding(.horizontal, Spacing.extraLarge)
              .padding(.vertical, Spacing.small)
              .background(Color.green.opacity(0.2))
              .cornerRadius(20)
          } else {
            Button(action: { showingQuiz = true }) {
              Text("\(event.price) Points")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, Spacing.extraLarge)
                .padding(.vertical, Spacing.small)
                .background(Color.blue)
                .cornerRadius(20)
            }
          }
        } else {
          Text("Your Event")
            .font(.headline)
            .foregroundColor(.gray)
            .padding(.horizontal, Spacing.extraLarge)
            .padding(.vertical, Spacing.small)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(20)
        }
      }
    }
    .padding(Spacing.default)
    .background(Color(.systemBackground))
    .cornerRadius(Spacing.medium)
    .shadow(radius: 2)
    .sheet(isPresented: $showingParticipants) {
      ParticipantsView(viewModel: ParticipantsViewModel(eventId: event.id))
        .presentationDetents([.medium])
    }
    .sheet(isPresented: $showingQuiz) {
      QuizView(eventId: event.id) { success in
        if success {
          showingPaymentAlert = true
        }
      }
    }
    .alert("Join Event", isPresented: $showingPaymentAlert) {
      Button("Cancel", role: .cancel) { }
      Button("Pay \(event.price) Points") {
        Task {
          await joinEvent()
        }
      }
    } message: {
      Text("Would you like to join this event for \(event.price) points?")
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
        amount: event.price,
        type: .purchase,
        description: "Joined event: \(event.title)"
      )
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

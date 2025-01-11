import SwiftUI

struct ParticipantRow: View {
  @StateObject private var viewModel: ParticipantViewModel
  
  init(userId: String) {
    self._viewModel = StateObject(wrappedValue: ParticipantViewModel(userId: userId))
  }
  
  var body: some View {
    HStack {
      if let imageUrl = viewModel.user.profileImageUrl {
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
          .fill(Color.gray.opacity(0.3))
          .frame(width: 40, height: 40)
          .overlay(
            Image(systemName: "person.crop.circle.fill")
              .resizable()
              .padding(8)
              .foregroundColor(.gray)
          )
      }

      VStack(alignment: .leading, spacing: Spacing.extraSmall) {
        Text(viewModel.user.name)
          .font(.headline)
        Text(viewModel.user.email)
          .font(.subheadline)
          .foregroundColor(.gray)
      }
      .padding(.leading, Spacing.small)
    }
    .padding(.vertical, Spacing.extraSmall)
  }
}

struct ParticipantsView: View {
  @StateObject private var viewModel: ParticipantsViewModel

  init(viewModel: @autoclosure @escaping () -> ParticipantsViewModel) {
    self._viewModel = StateObject(wrappedValue: viewModel())
  }

  var body: some View {
    List {
      ForEach(viewModel.participants, id: \.id) { participant in
        ParticipantRow(userId: participant.id)
      }
    }
    .navigationTitle("Participants")
    .navigationBarTitleDisplayMode(.inline)
    .task {
      await viewModel.fetchParticipants()
    }
  }
}

#Preview {
  NavigationStack {
    ParticipantsView(viewModel: ParticipantsViewModel(eventId: "event_001"))
  }
}

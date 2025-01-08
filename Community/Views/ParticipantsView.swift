import SwiftUI

struct ParticipantsView: View {
  @StateObject private var viewModel: ParticipantsViewModel

  init(viewModel: @autoclosure @escaping () -> ParticipantsViewModel) {
    self._viewModel = StateObject(wrappedValue: viewModel())
  }

  var body: some View {
    List {
      ForEach(viewModel.participants, id: \.id) { user in
        HStack {
          // The Circle is used as a placeholder for the user avatar
          Circle()
            .fill(Color.gray.opacity(0.3))
            .frame(width: 40, height: 40)

          VStack(alignment: .leading, spacing: Spacing.extraSmall) {
            Text(user.name)
              .font(.headline)
            Text(user.email)
              .font(.subheadline)
              .foregroundColor(.gray)
          }
          .padding(.leading, Spacing.small)
        }
        .padding(.vertical, Spacing.extraSmall)
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

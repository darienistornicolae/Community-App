import SwiftUI

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

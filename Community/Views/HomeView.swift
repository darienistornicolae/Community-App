import SwiftUI

struct HomeView: View {
  @StateObject var viewModel: HomeViewModel

  init(viewModel: @autoclosure @escaping () -> HomeViewModel) {
    self._viewModel = StateObject(wrappedValue: viewModel())
  }

  var body: some View {
    ZStack {
      NavigationStack {
        ScrollView {
          VStack(spacing: Spacing.default) {
            ForEach(viewModel.events) { event in
              EventCardView(
                event: event,
                currentUserId: viewModel.currentUserId,
                onJoin: {
                  Task {
                    await viewModel.joinEvent(event)
                  }
                }
              )
            }
          }
          .padding(.horizontal)
        }
        .navigationTitle("Community Events")
        .navigationBarTitleDisplayMode(.large)
        .refreshable {
          await viewModel.refresh()
        }
      }
      floatingButton
    }
  }
}

#Preview {
  HomeView(viewModel: HomeViewModel())
    .environmentObject(PointsManager.shared)
}

// MARK: Private
private extension HomeView {
  var floatingButton: some View {
    VStack {
      Spacer()
      HStack {
        Spacer()
        FloatingActionButton()
      }
      .padding(.bottom, Spacing.default)
    }
  }
}

import SwiftUI

struct HomeView: View {
  @ObservedObject var viewModel: HomeViewModel

  var body: some View {
    ZStack {
      NavigationStack {
        ScrollView {
          VStack(spacing: Spacing.large) {
            LazyVStack(spacing: Spacing.default) {
              ForEach(viewModel.events) { event in
                EventCard(
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

private extension HomeView {
  var floatingButton: some View {
    VStack {
      Spacer()
      HStack {
        Spacer()
        FloatingActionButton()
      }
      .padding(.bottom, Spacing.extraLarge)
    }
  }
}

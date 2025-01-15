import SwiftUI

struct CommunityView: View {
  @StateObject private var viewModel = CommunityViewModel()
  @State private var selectedQuiz: QuizModel?

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(spacing: Spacing.large) {
          if !viewModel.activeQuests.isEmpty {
            questsSection
          }

          if !viewModel.quizzes.isEmpty {
            quizzesSection
          }

        #if DEBUG
          Button("Publish Sample Quests") {
            Task {
              await PublishInitialQuests.publish()
              await viewModel.fetchData()
            }
          }
          .buttonStyle(.bordered)
          .padding(.top, Spacing.large)
        #endif
        }
        .padding()
      }
      .navigationTitle("Community")
      .overlay {
        if viewModel.isLoading {
          ProgressView()
        }
      }
      .refreshable {
        await viewModel.fetchData()
      }
      .task {
        await viewModel.fetchData()
      }
      .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
        Button("OK", role: .cancel) {
          viewModel.errorMessage = nil
        }
      } message: {
        if let errorMessage = viewModel.errorMessage {
          Text(errorMessage)
        }
      }
      .fullScreenCover(item: $selectedQuiz) { quiz in
        QuizView(eventId: quiz.id) { completed in
          if completed {
            Task {
              await viewModel.fetchData()
            }
          }
        }
      }
    }
  }
}

// MARK: Private
private extension CommunityView {
  var questsSection: some View {
    VStack(alignment: .leading, spacing: Spacing.medium) {
      Text("Active Quests")
        .font(.title2)
        .bold()
      
      ForEach(viewModel.activeQuests) { quest in
        QuestCardView(quest: quest)
      }
    }
  }

  var quizzesSection: some View {
    VStack(alignment: .leading, spacing: Spacing.medium) {
      Text("Available Quizzes")
        .font(.title2)
        .bold()

      ForEach(viewModel.quizzes) { quiz in
        Button {
          if !quiz.participants.contains(UserId.current.rawValue) {
            selectedQuiz = quiz
          }
        } label: {
          QuizCardView(quiz: quiz)
        }
        .buttonStyle(.plain)
      }
    }
  }
}

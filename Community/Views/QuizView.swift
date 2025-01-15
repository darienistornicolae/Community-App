import SwiftUI

struct QuizView: View {
  @Environment(\.dismiss) private var dismiss
  @StateObject private var viewModel: QuizViewModel
  let onComplete: (Bool) -> Void

  init(eventId: String, onComplete: @escaping (Bool) -> Void) {
    self._viewModel = StateObject(wrappedValue: QuizViewModel(eventId: eventId))
    self.onComplete = onComplete
  }

  var body: some View {
    NavigationStack {
      Group {
        if let quiz = viewModel.quiz {
          quizContent(quiz)
        } else {
          ProgressView()
        }
      }
      .navigationTitle("Quiz")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel") {
            dismiss()
          }
        }
      }
    }
    .task {
      await viewModel.fetchQuiz()
    }
  }
}

// MARK: - Private
private extension QuizView {
  func quizContent(_ quiz: QuizModel) -> some View {
    VStack(spacing: Spacing.large) {
      questionSection(quiz)
      answersSection(quiz)
      Spacer()
      resultSection(quiz)
    }
  }

  func questionSection(_ quiz: QuizModel) -> some View {
    VStack(spacing: Spacing.medium) {
      Text("Question")
        .font(.headline)
        .foregroundColor(.gray)

      Text(quiz.question)
        .font(.title3)
        .bold()
        .multilineTextAlignment(.center)
        .padding(.horizontal)

      if let imageUrl = quiz.imageUrl {
        CachedAsyncImage(url: imageUrl) { image in
          image
            .resizable()
            .scaledToFit()
            .frame(maxHeight: 200)
            .cornerRadius(Spacing.small)
        } placeholder: {
          ProgressView()
            .frame(height: 200)
        }
        .padding(.horizontal)
      }
    }
    .padding(.top)
  }

  func answersSection(_ quiz: QuizModel) -> some View {
    VStack(spacing: Spacing.medium) {
      ForEach(quiz.answers.indices, id: \.self) { index in
        answerButton(quiz.answers[index], index: index)
      }
    }
    .padding(.horizontal)
  }

  func answerButton(_ answer: String, index: Int) -> some View {
    Button {
      withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
        viewModel.selectedAnswerIndex = index
      }
    } label: {
      HStack {
        Text(answer)
          .foregroundColor(answerTextColor(for: index))
          .multilineTextAlignment(.leading)
        Spacer()
        if viewModel.selectedAnswerIndex == index {
          Image(systemName: "checkmark.circle.fill")
            .foregroundColor(.white)
            .transition(.scale.combined(with: .opacity))
        }
      }
      .padding()
      .background(
        RoundedRectangle(cornerRadius: Spacing.small)
          .fill(answerBackgroundColor(for: index))
      )
      .overlay(
        RoundedRectangle(cornerRadius: Spacing.small)
          .stroke(answerBorderColor(for: index), lineWidth: Spacing.onePointSmall)
      )
      .shadow(
        color: viewModel.selectedAnswerIndex == index ?
        Color.blue.opacity(0.3) : Color.black.opacity(0.1),
        radius: viewModel.selectedAnswerIndex == index ? 8 : 2
      )
      .scaleEffect(viewModel.selectedAnswerIndex == index ? 1.02 : 1.0)
    }
    .buttonStyle(.plain)
    .disabled(viewModel.quizResult != nil)
  }

  func resultSection(_ quiz: QuizModel) -> some View {
    Group {
      if let result = viewModel.quizResult {
        quizResultView(result: result, quiz: quiz)
      } else {
        submitButton
      }
    }
    .padding([.horizontal, .bottom])
  }

  var submitButton: some View {
    Button {
      withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
        viewModel.submitAnswer()
      }
    } label: {
      Text("Submit Answer")
        .font(.headline)
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .padding()
        .background(
          viewModel.selectedAnswerIndex != nil ? Color.blue : Color.gray
        )
        .cornerRadius(Spacing.small)
    }
    .disabled(viewModel.selectedAnswerIndex == nil)
  }

  func quizResultView(result: Bool, quiz: QuizModel) -> some View {
    VStack(spacing: Spacing.large) {
      resultHeader(result: result, quiz: quiz)
      if let achievement = viewModel.unlockedAchievement {
        achievementUnlockedView(achievement)
      }
      actionButton(result: result)
    }
    .transition(.opacity.animation(.easeInOut))
  }

  func resultHeader(result: Bool, quiz: QuizModel) -> some View {
    VStack(spacing: Spacing.medium) {
      Image(systemName: result ? "checkmark.circle.fill" : "xmark.circle.fill")
        .font(.system(size: 60))
        .foregroundColor(result ? .green : .red)
        .transition(.scale.combined(with: .opacity))

      VStack(spacing: Spacing.small) {
        Text(result ? "Correct!" : "Sorry, try again!")
          .font(.title2)
          .bold()

        if result {
          Text("You've earned \(quiz.points) points!")
            .foregroundColor(.green)
        }
      }
    }
  }

  func achievementUnlockedView(_ achievement: Asset) -> some View {
    VStack(spacing: Spacing.medium) {
      Text("Achievement Unlocked! 🎉")
        .font(.headline)
        .foregroundColor(.orange)

      HStack(spacing: Spacing.medium) {
        Image(achievement.rawValue)
          .resizable()
          .scaledToFit()
          .frame(width: 60, height: 60)
          .clipShape(RoundedRectangle(cornerRadius: Spacing.small))

        VStack(alignment: .leading, spacing: Spacing.extraSmall) {
          Text(achievement.displayName)
            .font(.headline)
          Text("New country unlocked!")
            .font(.subheadline)
            .foregroundColor(.gray)
        }
      }
    }
    .padding()
    .background(
      RoundedRectangle(cornerRadius: Spacing.small)
        .fill(Color.orange.opacity(0.1))
    )
    .padding(.horizontal)
    .transition(.move(edge: .bottom).combined(with: .opacity))
  }
  
  func actionButton(result: Bool) -> some View {
    Button {
      withAnimation {
        if result {
          dismiss()
          onComplete(true)
        } else {
          viewModel.reset()
        }
      }
    } label: {
      Text(result ? "Continue" : "Try Again")
        .font(.headline)
        .foregroundColor(.white)
        .frame(maxWidth: .infinity)
        .padding()
        .background(result ? Color.blue : Color.red)
        .cornerRadius(Spacing.small)
    }
  }

  func answerBackgroundColor(for index: Int) -> Color {
    if viewModel.selectedAnswerIndex == index {
      return Color.blue
    }
    return Color(.systemBackground)
  }

  func answerBorderColor(for index: Int) -> Color {
    if viewModel.selectedAnswerIndex == index {
      return Color.blue
    }
    return Color.gray.opacity(0.3)
  }

  func answerTextColor(for index: Int) -> Color {
    if viewModel.selectedAnswerIndex == index {
      return .white
    }
    return .primary
  }
}

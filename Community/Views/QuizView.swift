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
          VStack(spacing: Spacing.large) {
            // Question Section
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
                AsyncImage(url: URL(string: imageUrl)) { image in
                  image
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                } placeholder: {
                  RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.1))
                    .frame(height: 200)
                    .overlay(
                      ProgressView()
                    )
                }
                .padding(.horizontal)
              }
            }
            .padding(.top)
            
            // Answers Section
            VStack(spacing: Spacing.medium) {
              ForEach(quiz.answers.indices, id: \.self) { index in
                Button {
                  withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    viewModel.selectedAnswerIndex = index
                  }
                } label: {
                  HStack {
                    Text(quiz.answers[index])
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
                    RoundedRectangle(cornerRadius: 10)
                      .fill(answerBackgroundColor(for: index))
                  )
                  .overlay(
                    RoundedRectangle(cornerRadius: 10)
                      .stroke(answerBorderColor(for: index), lineWidth: 2)
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
            }
            .padding(.horizontal)

            Spacer()

            // Result Section
            if let result = viewModel.quizResult {
              VStack(spacing: Spacing.large) {
                // Result Icon and Text
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
                
                // Achievement Section (if unlocked)
                if let achievement = viewModel.unlockedAchievement {
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
                      
                      VStack(alignment: .leading, spacing: 4) {
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
                    RoundedRectangle(cornerRadius: 12)
                      .fill(Color.orange.opacity(0.1))
                  )
                  .padding(.horizontal)
                  .transition(.move(edge: .bottom).combined(with: .opacity))
                }

                // Action Button
                Button {
                  withAnimation {
                    if result {
                      onComplete(true)
                      dismiss()
                    } else {
                      viewModel.reset()
                    }
                  }
                } label: {
                  Text(result ? "Join Event" : "Try Again")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(result ? Color.blue : Color.red)
                    .cornerRadius(10)
                }
                .padding(.horizontal)
              }
              .padding(.bottom)
              .transition(.opacity.animation(.easeInOut))
            } else {
              // Submit Button
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
                  .cornerRadius(10)
              }
              .disabled(viewModel.selectedAnswerIndex == nil)
              .padding([.horizontal, .bottom])
            }
          }
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
  
  private func answerBackgroundColor(for index: Int) -> Color {
    if viewModel.selectedAnswerIndex == index {
      return Color.blue
    }
    return Color(.systemBackground)
  }
  
  private func answerBorderColor(for index: Int) -> Color {
    if viewModel.selectedAnswerIndex == index {
      return Color.blue
    }
    return Color.gray.opacity(0.3)
  }
  
  private func answerTextColor(for index: Int) -> Color {
    if viewModel.selectedAnswerIndex == index {
      return .white
    }
    return .primary
  }
}

#Preview {
  QuizView(eventId: "event_001") { _ in }
}

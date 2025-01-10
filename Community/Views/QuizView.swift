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
            Text(quiz.question)
              .font(.title3)
              .multilineTextAlignment(.center)
              .padding()
            
            VStack(spacing: Spacing.medium) {
              ForEach(quiz.answers.indices, id: \.self) { index in
                Button {
                  viewModel.selectedAnswerIndex = index
                } label: {
                  HStack {
                    Text(quiz.answers[index])
                      .foregroundColor(.primary)
                    Spacer()
                    if viewModel.selectedAnswerIndex == index {
                      Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                    }
                  }
                  .padding()
                  .background(
                    RoundedRectangle(cornerRadius: 10)
                      .fill(Color(.systemBackground))
                      .shadow(radius: 2)
                  )
                }
              }
            }
            .padding()

            Spacer()

            if let result = viewModel.quizResult {
              VStack(spacing: Spacing.small) {
                Image(systemName: result ? "checkmark.circle.fill" : "xmark.circle.fill")
                  .font(.system(size: 60))
                  .foregroundColor(result ? .green : .red)
                
                Text(result ? "Correct! You can join the event." : "Sorry, try again!")
                  .font(.headline)
              }
              .padding()

              Button {
                if result {
                  onComplete(true)
                  dismiss()
                } else {
                  viewModel.reset()
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
              .padding()
            } else {
              Button {
                viewModel.submitAnswer()
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
              .padding()
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
}

#Preview {
  QuizView(eventId: "event_001") { _ in }
}

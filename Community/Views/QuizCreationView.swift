import SwiftUI

struct QuizCreationView: View {
  @Environment(\.dismiss) private var dismiss
  @StateObject private var viewModel = QuizCreationViewModel()

  var body: some View {
    NavigationStack {
      Form {
        Section("Question") {
          TextField("Enter your question", text: $viewModel.question)
            .textInputAutocapitalization(.sentences)
        }

        Section("Answers") {
          ForEach(0..<4) { index in
            HStack(spacing: Spacing.medium) {
              Image(systemName: viewModel.correctAnswerIndex == index ? "checkmark.circle.fill" : "circle")
                .foregroundColor(.blue)
                .onTapGesture {
                  viewModel.correctAnswerIndex = index
                }
              
              TextField("Answer \(index + 1)", text: $viewModel.answers[index])
                .textInputAutocapitalization(.sentences)
            }
          }
        }

        Section {
          Stepper("Points: \(viewModel.points)", value: $viewModel.points, in: 5...50, step: 5)
        }
        
        if !viewModel.availableAchievements.isEmpty {
          Section("Achievement Reward (Optional)") {
            if let selected = viewModel.selectedAchievement {
              HStack {
                Spacer()
                VStack(spacing: Spacing.small) {
                  Image(selected.rawValue)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 60)
                    .clipShape(RoundedRectangle(cornerRadius: Spacing.small))
                  
                  Text(selected.displayName)
                    .font(.caption)
                }
                Spacer()
              }
              .padding(.vertical, Spacing.small)
              
              Button("Remove Achievement", role: .destructive) {
                viewModel.selectedAchievement = nil
              }
            } else {
              ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: Spacing.medium) {
                  ForEach(viewModel.availableAchievements, id: \.self) { achievement in
                    VStack {
                      Image(achievement.rawValue)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 60)
                        .clipShape(RoundedRectangle(cornerRadius: Spacing.small))
                      
                      Text(achievement.displayName)
                        .font(.caption)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                    }
                    .frame(height: 100)
                    .padding(Spacing.small)
                    .background(Color(.systemBackground))
                    .cornerRadius(Spacing.medium)
                    .onTapGesture {
                      viewModel.selectedAchievement = achievement
                    }
                  }
                }
                .padding(.horizontal, Spacing.small)
              }
            }
          }
        }
      }
      .navigationTitle("Create Quiz")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel") {
            dismiss()
          }
        }

        ToolbarItem(placement: .confirmationAction) {
          Button("Create") {
            Task {
              await viewModel.createQuiz()
              if !viewModel.showError {
                dismiss()
              }
            }
          }
          .disabled(!viewModel.isValid)
        }
      }
      .alert("Error", isPresented: $viewModel.showError) {
        Button("OK", role: .cancel) { }
      } message: {
        Text(viewModel.errorMessage ?? "An unknown error occurred")
      }
    }
  }
}

#Preview {
  QuizCreationView()
}

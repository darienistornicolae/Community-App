import SwiftUI
import PhotosUI

struct QuizCreationView: View {
  @Environment(\.dismiss) private var dismiss
  @StateObject private var viewModel = QuizCreationViewModel()
  @State private var selectedItem: PhotosPickerItem?

  var body: some View {
    NavigationStack {
      Form {
        questionSection
        imageSection
        answersSection
        pointsSection
        if !viewModel.availableAchievements.isEmpty {
          achievementSection
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
      .onChange(of: selectedItem) { oldValue, newValue in
        if let item = newValue {
          Task {
            await viewModel.uploadImage(item)
          }
        }
      }
    }
  }
}

// MARK: - Sections
private extension QuizCreationView {
  var questionSection: some View {
    Section("Question") {
      TextField("Enter your question", text: $viewModel.question)
        .textInputAutocapitalization(.sentences)
    }
  }

  var imageSection: some View {
    Section("Image (Optional)") {
      if let imageUrl = viewModel.imageUrl {
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

        Button("Remove Image", role: .destructive) {
          viewModel.imageUrl = nil
        }
      } else {
        PhotosPicker(selection: $selectedItem, matching: .images) {
          Label("Add Image", systemImage: "photo")
        }
      }
    }
  }
  
  var answersSection: some View {
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
  }

  var pointsSection: some View {
    Section {
      Stepper("Points: \(viewModel.points)", value: $viewModel.points, in: 5...50, step: 5)
    }
  }

  var achievementSection: some View {
    Section("Achievement Reward (Optional)") {
      if let selected = viewModel.selectedAchievement {
        selectedAchievementView(selected)
      } else {
        availableAchievementsView
      }
    }
  }

  func selectedAchievementView(_ achievement: Asset) -> some View {
    VStack {
      HStack {
        Spacer()
        VStack(spacing: Spacing.small) {
          Image(achievement.rawValue)
            .resizable()
            .scaledToFit()
            .frame(width: 80, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: Spacing.small))
          
          Text(achievement.displayName)
            .font(.caption)
        }
        Spacer()
      }
      .padding(.vertical, Spacing.small)
      
      Button("Remove Achievement", role: .destructive) {
        viewModel.selectedAchievement = nil
      }
    }
  }

  var availableAchievementsView: some View {
    ScrollView(.horizontal, showsIndicators: false) {
      HStack(spacing: Spacing.medium) {
        ForEach(viewModel.availableAchievements, id: \.self) { achievement in
          achievementCell(achievement)
        }
      }
      .padding(.horizontal, Spacing.small)
    }
  }

  func achievementCell(_ achievement: Asset) -> some View {
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

#Preview {
  QuizCreationView()
}

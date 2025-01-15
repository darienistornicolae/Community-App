import SwiftUI
import PhotosUI

struct QuizCreationView: View {
  @Environment(\.dismiss) private var dismiss
  @StateObject private var viewModel = QuizCreationViewModel()
  @State private var selectedItem: PhotosPickerItem?
  @State private var previewImage: Image?
  @State private var isLoadingImage = false

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
              if let item = selectedItem {
                await viewModel.uploadImage(item)
              }
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
      .onChange(of: selectedItem) { _, newValue in
        if let item = newValue {
          loadPreviewImage(from: item)
        } else {
          previewImage = nil
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
      if let image = previewImage {
        VStack(alignment: .leading, spacing: Spacing.medium) {
          image
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(maxWidth: .infinity)
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 12))

          Button(role: .destructive) {
            selectedItem = nil
          } label: {
            Label("Remove Image", systemImage: "trash")
          }
        }
      } else {
        if isLoadingImage {
          RoundedRectangle(cornerRadius: 12)
            .fill(Color.gray.opacity(0.1))
            .frame(maxWidth: .infinity)
            .frame(height: 200)
            .overlay(
              ProgressView()
            )
        } else {
          PhotosPicker(selection: $selectedItem, matching: .images) {
            Label("Add Image", systemImage: "photo")
          }
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
      Text("Quiz Points")
        .font(.headline)

      Text("Points awarded to participants for correct answers. These points contribute to their community score and leaderboard position.")
        .font(.caption)
        .foregroundColor(.gray)
      Stepper("Points: \(viewModel.points)", value: $viewModel.points, in: 5...50, step: 5)
    }
  }

  var achievementSection: some View {
    Section {
      Text("Achievement Reward")
        .font(.headline)
      Text("Select a country flag that participants will unlock when they correctly answer this quiz. (Optional)")
        .font(.caption)
        .foregroundColor(.gray)
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

  func loadPreviewImage(from item: PhotosPickerItem) {
    isLoadingImage = true
    Task {
      if let data = try? await item.loadTransferable(type: Data.self),
         let uiImage = UIImage(data: data) {
        await MainActor.run {
          previewImage = Image(uiImage: uiImage)
          isLoadingImage = false
        }
      }
    }
  }
}

#Preview {
  QuizCreationView()
}

import SwiftUI

class OnboardingViewModel: ObservableObject {
  @Published var currentStepIndex: Int = 0
  let steps: [OnboardingStepModel]

  init() {
    self.steps = [
      OnboardingStepModel(title: "Welcome to Nieghborly", description: "Grow closer with your community", image: "Onboarding"),
      OnboardingStepModel(title: "Explore local cultures", description: "Complete cultural quizzes to earn points and flags", image: "Onboarding2"),
      OnboardingStepModel(title: "Meet new people", description: "Join your neighbors, attend local events using your points", image: "Onboarding3"),
      OnboardingStepModel(title: "Collect them all", description: "Collect flags by completing quizzes and joining events", image: "Onboarding4"),
      OnboardingStepModel(title: "Band together", description: "Join your neighbors, and complete community quests together", image: "Onboarding5"),
      OnboardingStepModel(title: "You're all set", description: "Enjoy connecting with neighbors, and becoming a stronger community", image: "Onboarding6")
    ]
  }

  var isLastStep: Bool {
    currentStepIndex == steps.count - 1
  }

  func nextStep() {
    if !isLastStep {
      currentStepIndex += 1
    }
  }
}

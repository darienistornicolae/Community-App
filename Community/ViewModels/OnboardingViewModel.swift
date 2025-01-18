import SwiftUI
import Combine

class OnboardingViewModel: ObservableObject {
    @Published var currentStepIndex: Int = 0
    let steps: [OnboardingStep]
    
    init() {
        self.steps = [
            OnboardingStep(title: "Welcome to Nieghborly", description: "Grow closer with your community", image: "Onboarding"),
            OnboardingStep(title: "Explore local cultures", description: "Complete cultural quizzes to earn points and flags", image: "Onboarding2"),
            OnboardingStep(title: "Meet new people", description: "Join your neighbors, attend local events using your points", image: "Onboarding3"),
            OnboardingStep(title: "Collect them all", description: "Collect flags by completing quizzes and joining events", image: "Onboarding4"),
            OnboardingStep(title: "Band together", description: "Join your neighbors, and complete community quests together", image: "Onboarding5"),
            OnboardingStep(title: "You're all set", description: "Enjoy connecting with neighbors, and becoming a stronger community", image: "Onboarding6")
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

import Foundation

struct OnboardingStep: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let image: String?
}


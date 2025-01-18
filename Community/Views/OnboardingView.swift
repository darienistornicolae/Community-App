import SwiftUI

struct OnboardingView: View {
  let onCompletion: () -> Void

  @StateObject private var viewModel = OnboardingViewModel()

  var body: some View {
    VStack {
      ProgressView(value: Double(viewModel.currentStepIndex + 1), total: Double(viewModel.steps.count))
        .progressViewStyle(LinearProgressViewStyle())
        .padding(.top, 20)
        .padding(.horizontal)

      Spacer()

      Text(viewModel.steps[viewModel.currentStepIndex].title)
        .font(.title)
        .fontWeight(.bold)
        .padding()

      if let imageName = viewModel.steps[viewModel.currentStepIndex].image {
        Image(imageName)
          .resizable()
          .frame(width: 300, height: 200)
          .clipped()
          .padding()
      }

      Text(viewModel.steps[viewModel.currentStepIndex].description)
        .font(.body)
        .padding()
        .multilineTextAlignment(.center)

      Spacer()

      Button {
        if viewModel.isLastStep {
          onCompletion()
        } else {
          viewModel.nextStep()
        }
      } label: {
        Text(viewModel.isLastStep ? "Get Started" : "Continue")
          .font(.headline)
          .padding()
          .frame(maxWidth: .infinity)
          .background(Color.blue)
          .foregroundColor(.white)
          .cornerRadius(10)
          .padding(.horizontal)
      }
    }
    .padding()
  }
}

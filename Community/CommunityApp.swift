import SwiftUI

@main
struct CommunityApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
  @StateObject private var pointsManager = PointsManager.shared
  @State private var hasCompletedOnboarding: Bool = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")

  var body: some Scene {
    WindowGroup {
      if hasCompletedOnboarding {
        LoginCheckView()
          .environmentObject(pointsManager)
          .preferredColorScheme(.light)
      } else {
        OnboardingView {
          UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
          hasCompletedOnboarding = true
        }
      }
    }
  }
}

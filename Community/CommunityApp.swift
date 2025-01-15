import SwiftUI

@main
struct CommunityApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
  @StateObject private var pointsManager = PointsManager.shared

  var body: some Scene {
    WindowGroup {
      LoginCheckView()
        .environmentObject(pointsManager)
        .preferredColorScheme(.light)
    }
  }
}

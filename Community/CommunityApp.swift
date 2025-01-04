import SwiftUI

@main
struct CommunityApp: App {
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

  var body: some Scene {
    WindowGroup {
      LoginCheckView()
    }
  }
}

import SwiftUI
 
struct TabBarController: View {
  @StateObject private var homeViewModel = HomeViewModel()
  var body: some View {
    TabView {
      HomeView(viewModel: homeViewModel)
        .tabItem {
          Label("Home", systemImage: "house.fill")
        }

      CommunityView()
        .tabItem {
          Label("Community", systemImage: "person.3.fill")
        }

      AchievementsView()
        .tabItem {
          Label("Achievements", systemImage: "globe")
        }

      ProfileView()
        .tabItem {
          Label("Profile", systemImage: "person.fill")
        }
    }
  }
}

#Preview {
  TabBarController()
}

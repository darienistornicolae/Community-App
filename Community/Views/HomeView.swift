import SwiftUI

struct HomeView: View {
  @StateObject private var viewModel = HomeViewModel()
  @Environment(\.colorScheme) private var colorScheme

  var body: some View {
    ZStack {
      ScrollView {}
      VStack {
        Spacer()
        HStack {
          Spacer()
          FloatingActionButton()
        }
      }
    }
  }
}

#Preview {
  HomeView()
}

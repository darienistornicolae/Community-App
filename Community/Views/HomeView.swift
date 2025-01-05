import SwiftUI

struct HomeView: View {
  @StateObject private var viewModel = HomeViewModel()
  @Environment(\.colorScheme) private var colorScheme

  var body: some View {
    ZStack {
      ScrollView {
        VStack(spacing: 20) {
          // Points Display
          HStack {
            Spacer()
            VStack {
              HStack {
                Image(systemName: "star.circle.fill")
                  .foregroundColor(.yellow)
                Text("\(viewModel.currentPoints)")
                  .font(.title)
                  .bold()
              }
              Text("POINTS")
                .font(.caption)
                .foregroundColor(.gray)
            }
            .padding()
            .background(colorScheme == .dark ? Color(.systemGray6) : .white)
            .cornerRadius(15)
            .shadow(radius: 2)
            Spacer()
          }
          .padding(.top)
          
          Spacer()
        }
      }
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

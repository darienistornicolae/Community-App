import SwiftUI

struct LoginView: View {
  @StateObject private var viewModel = LoginViewModel()
  var body: some View {
    NavigationStack {
      ZStack {
        Color.blue
          .ignoresSafeArea()
        Circle()
          .scale(1.7)
          .foregroundColor(.white.opacity(0.15))
        Circle()
          .scale(1.35)
          .foregroundColor(.white)
        
        VStack {
          Text("Login")
            .font(.largeTitle)
            .bold()
            .padding()
          
          TextField("Username", text: $viewModel.username)
            .padding()
            .frame(width: 300, height: 50)
            .background(Color.black.opacity(0.05))
            .cornerRadius(10)
            .border(.red, width: CGFloat(viewModel.wrongUsername))
          
          
          SecureField("Password", text: $viewModel.password)
            .padding()
            .frame(width: 300, height: 50)
            .background(Color.black.opacity(0.05))
            .cornerRadius(10)
            .border(.red, width: CGFloat(viewModel.wrongPassword))
          
          Button("Login") {
            viewModel.authenticateUser(username: viewModel.username,password: viewModel.password)
          }
          .foregroundColor(.white)
          .frame(width: 300, height: 50)
          .background(Color.blue)
          .cornerRadius(10)
          
          NavigationLink(value: viewModel.username) {
            EmptyView()
          }
          .hidden()
          .navigationDestination(for: String.self) { username in
            Text("You are logged in @\(username)")
          }
          //                      NavigationLink(destination: Text("You are logged in @\(viewModel.username)"), isActive: $viewModel.isShowingLoginScreen) {
          //                            EmptyView()
          //                        }
        }
      }.navigationBarHidden(true)
    }
  }
}

import SwiftUI

@MainActor
class LoginViewModel: ObservableObject {
  @Published var username = ""
  @Published var password = ""
  @Published var wrongUsername: Float = 0
  @Published var wrongPassword: Float  = 0
  @AppStorage("isShowingLoginScreen") var isShowingLoginScreen: Bool = false
  
  func authenticateUser(username: String, password: String) {
    if username.lowercased() == "mario2021" {
      wrongUsername = 0
      if password.lowercased() == "abc123" {
        wrongPassword = 0
        isShowingLoginScreen = true
      } else {
        wrongPassword = 2
      }
    } else {
      wrongUsername = 2
    }
  }
}

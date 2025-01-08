import SwiftUI

struct LoginCheckView: View {
  @AppStorage("isShowingLoginScreen") private var isShowingLoginScreen: Bool = false
  
  var body: some View {
//    if isShowingLoginScreen{
      TabBarController()
    }
//    else {
//      LoginView()
//    }
//  }
}

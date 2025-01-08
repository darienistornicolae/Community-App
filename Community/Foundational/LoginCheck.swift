import SwiftUI

struct LoginCheckView: View {
  @AppStorage("isShowingLoginScreen") private var isShowingLoginScreen: Bool = false
  
  var body: some View {
      TabBarController()

  }
}

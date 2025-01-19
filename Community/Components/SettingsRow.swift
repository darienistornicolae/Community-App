import Foundation
import SwiftUI

struct SettingsRow: View {
  let icon: String
  let title: String
  let color: Color
  var showNavigation: Bool = true
  var action: (() -> Void)? = nil

  var body: some View {
    HStack {
      Image(systemName: icon)
        .foregroundColor(color)
        .frame(width: 24)

      Text(title)

      if showNavigation {
        Spacer()
        Image(systemName: "chevron.right")
          .font(.system(size: 14))
          .foregroundColor(.primaryColour)
      }
    }
    .onTapGesture {
      action?()
    }
  }
}

#Preview {
  SettingsRow(icon: "person", title: "Profile", color: .blue)
    .padding()
}

import SwiftUI

extension View {
  func profileImageStyle(size: CGFloat = 180) -> some View {
    self
      .frame(width: size, height: size)
      .clipShape(Circle())
      .overlay(Circle().stroke(Color.gray.opacity(0.2), lineWidth: Spacing.halfPointSmall))
      .shadow(color: .black.opacity(0.1), radius: Spacing.small, x: 0, y: Spacing.extraSmall)
  }
}

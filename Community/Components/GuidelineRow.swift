import SwiftUI

struct GuidelineRow: View {
  let icon: String
  let text: String

  var body: some View {
    HStack(spacing: Spacing.medium) {
      Image(systemName: icon)
        .font(.system(size: 24))
        .foregroundColor(.blue)
        .frame(width: Spacing.extraExtraLarge)
      
      Text(text)
        .font(.subheadline)
    }
  }
}

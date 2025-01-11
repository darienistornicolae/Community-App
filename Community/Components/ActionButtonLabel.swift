import SwiftUI

struct ActionButtonLabel: View {
  let icon: String
  let text: String
  let color: Color
  var style: ButtonStyle = .filled

  enum ButtonStyle {
    case filled, outline
  }

  var body: some View {
    HStack {
      Image(systemName: icon)
        .font(.headline)
      Text(text)
        .font(.headline)
    }
    .foregroundColor(style == .filled ? .white : color)
    .frame(maxWidth: .infinity)
    .padding()
    .background(
      style == .filled
      ? color
      : color.opacity(0.1)
    )
    .clipShape(RoundedRectangle(cornerRadius: Spacing.medium))
  }
}

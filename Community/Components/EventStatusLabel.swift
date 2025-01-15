import Foundation
import SwiftUI

struct EventStatusLabel: View {
  let title: String
  let icon: String
  let color: Color
  let action: (() -> Void)?

  init(
    title: String,
    icon: String,
    color: Color,
    action: (() -> Void)? = nil
  ) {
    self.title = title
    self.icon = icon
    self.color = color
    self.action = action
  }

  var body: some View {
    Group {
      if let action = action {
        Button(action: action) {
          label
        }
      } else {
        label
      }
    }
  }

  private var label: some View {
    Label(title, systemImage: icon)
      .font(.subheadline)
      .foregroundColor(action == nil ? color : .white)
      .padding(.horizontal, 12)
      .padding(.vertical, 6)
      .background(action == nil ? color.opacity(0.2) : color)
      .clipShape(Capsule())
  }
}

enum EventStatus {
  case ended
  case creator
  case joined
  case joinable(points: Int)

  var title: String {
    switch self {
    case .ended:
      return "Event Ended"
    case .creator:
      return "Your Event"
    case .joined:
      return "Joined"
    case .joinable(let points):
      return "Join for \(points) Points"
    }
  }

  var icon: String {
    switch self {
    case .ended:
      return "clock.fill"
    case .creator:
      return "star.fill"
    case .joined:
      return "checkmark.circle.fill"
    case .joinable:
      return ""
    }
  }

  var color: Color {
    switch self {
    case .ended:
      return .gray
    case .creator:
      return .orange
    case .joined:
      return .green
    case .joinable:
      return .blue
    }
  }

  var isJoinable: Bool {
    if case .joinable = self {
      return true
    }
    return false
  }
}

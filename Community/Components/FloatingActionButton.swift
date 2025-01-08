import SwiftUI

private enum PresentationView: Identifiable {
  case quizCreation
  case eventCreation

  var id: Self { self }
}

struct FloatingActionButton: View {
  @State private var isExpanded: Bool = false
  @State private var presentationView: PresentationView?
  var body: some View {
    ZStack {
      if isExpanded {
        quizCreationButton
        eventCreationButton
      }
      primaryButton
    }
    .padding()
    .fullScreenCover(item: $presentationView) { item in
      switch item {
      case .quizCreation:
        ProfileView()
      case .eventCreation:
        EventCreationView()
      }
    }
  }
}

#Preview {
  FloatingActionButton()
}

// MARK: Private
private extension FloatingActionButton {
  var primaryButton: some View {
    Button {
      withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
        isExpanded.toggle()
      }
    } label: {
      Image(systemName: "plus")
        .foregroundColor(.white)
        .font(.system(size: Spacing.extraLarge, weight: .bold))
        .frame(width: 60, height: 60)
        .background(Color.blue)
        .clipShape(Circle())
        .shadow(radius: 4)
        .rotationEffect(.degrees(isExpanded ? 45 : 0))
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isExpanded)
    }
  }

  var quizCreationButton: some View {
    Button {

    } label: {
      Image(systemName: "questionmark.circle.fill")
        .foregroundColor(.white)
        .font(.system(size: Spacing.large))
        .frame(width: 45, height: 45)
        .background(Color.blue)
        .clipShape(Circle())
        .shadow(radius: 4)
    }
    .offset(y: -120)
    .transition(.move(edge: .bottom).combined(with: .opacity))
    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isExpanded)
  }

  var eventCreationButton: some View {
    Button {
      presentationView = .eventCreation
    } label: {
      Image(systemName: "square.and.pencil")
        .foregroundColor(.white)
        .font(.system(size: Spacing.large))
        .frame(width: 45, height: 45)
        .background(Color.blue)
        .clipShape(Circle())
        .shadow(radius: 4)
    }
    .offset(y: -60)
    .transition(.move(edge: .bottom).combined(with: .opacity))
    .animation(.spring(response: 0.4, dampingFraction: 0.7).delay(0.1), value: isExpanded)
  }
}

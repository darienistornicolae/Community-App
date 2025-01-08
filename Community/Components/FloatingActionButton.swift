import SwiftUI

struct FloatingActionButton: View {
  @State private var isExpanded: Bool = false
  var body: some View {
    NavigationStack {
      ZStack(alignment: .bottomTrailing){
        Color.clear
          .edgesIgnoringSafeArea(.all)
        if isExpanded {
          quizCreationButton
          eventCreationButton
        }
        
        primaryButton
      }
      .padding()
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
    NavigationLink{
      QuizCreationView()
      
    } label: {
      Image(systemName: "questionmark.circle.fill")
        .foregroundColor(.white)
        .font(.system(size: Spacing.large))
        .frame(width: 45, height: 45)
        .background(Color.blue)
        .clipShape(Circle())
        .shadow(radius: 4)
    }
    .offset(y: -130)
    .transition(.move(edge: .bottom).combined(with: .opacity))
    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isExpanded)
  }
  
  var eventCreationButton: some View {
    NavigationLink{
      EventCreationView()
    } label: {
      Image(systemName: "square.and.pencil")
        .foregroundColor(.white)
        .font(.system(size: Spacing.large))
        .frame(width: 45, height: 45)
        .background(Color.blue)
        .clipShape(Circle())
        .shadow(radius: 4)
    }
    .offset(y: -70)
    .transition(.move(edge: .bottom).combined(with: .opacity))
    .animation(.spring(response: 0.4, dampingFraction: 0.7).delay(0.1), value: isExpanded)
  }
}



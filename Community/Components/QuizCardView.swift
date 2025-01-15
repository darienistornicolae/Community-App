import Foundation
import SwiftUI

struct QuizCardView: View {
  let quiz: QuizModel

  var body: some View {
    VStack(alignment: .leading, spacing: Spacing.medium) {
      if let imageUrl = quiz.imageUrl {
        CachedAsyncImage(url: imageUrl) { image in
          image
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(height: 120)
            .clipShape(RoundedRectangle(cornerRadius: Spacing.small))
        } placeholder: {
          RoundedRectangle(cornerRadius: Spacing.small)
            .fill(Color.gray.opacity(0.1))
            .frame(height: 120)
        }
      }

      VStack(alignment: .leading, spacing: Spacing.small) {
        Text(quiz.question)
          .font(.headline)
          .lineLimit(2)

        HStack {
          Label("\(quiz.points) points", systemImage: "star.fill")
            .font(.caption)
            .foregroundColor(.orange)

          Spacer()

          if quiz.participants.contains(UserId.current.rawValue) {
            Label("Completed", systemImage: "checkmark.circle.fill")
              .font(.caption)
              .foregroundColor(.green)
          }
        }
      }
    }
    .padding()
    .background(Color(.systemBackground))
    .clipShape(RoundedRectangle(cornerRadius: Spacing.medium))
    .shadow(color: .black.opacity(0.1), radius: 5)
  }
}

import Foundation
import SwiftUI

struct QuestCardView: View {
  let quest: QuestModel

  var body: some View {
    VStack(alignment: .leading, spacing: Spacing.medium) {
      HStack {
        VStack(alignment: .leading, spacing: Spacing.small) {
          Text(quest.title)
            .font(.headline)


          Text(quest.requirement.description)
            .font(.subheadline)
            .foregroundColor(.black)
        }

        Spacer()

        Text("\(quest.points) pts")
          .font(.headline)
          .foregroundColor(.accentColour)
      }

      GeometryReader { geometry in
        ZStack(alignment: .leading) {
          RoundedRectangle(cornerRadius: Spacing.small)
            .fill(Color.gray.opacity(0.2))
            .frame(height: 8)

          RoundedRectangle(cornerRadius: Spacing.small)
            .fill(Color.accentColour)
            .frame(width: geometry.size.width * quest.progressPercentage, height: 8)
        }
      }
      .frame(height: 8)
      .animation(.spring(response: 0.3), value: quest.progressPercentage)

      HStack {
        Label(quest.endDate.formatted(date: .abbreviated, time: .omitted), systemImage: "calendar")
          .font(.caption)
          .foregroundColor(.accentColour)

        Spacer()

        if let total = quest.requirement.totalRequired {
          Text("\(quest.currentUserProgress)/\(total)")
            .font(.caption)
            .foregroundColor(.black)
        }
        
        if quest.isCompleted {
          Label("Completed", systemImage: "checkmark.circle.fill")
            .font(.caption)
            .foregroundColor(.green)
        }
      }
    }
    .padding()
    .background(Color.secondaryColour)
    .clipShape(RoundedRectangle(cornerRadius: Spacing.medium))
    .shadow(color: .black.opacity(0.1), radius: 5)
  }
}

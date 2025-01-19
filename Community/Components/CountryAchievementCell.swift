import SwiftUI

struct CountryAchievementCell: View {
  let achievement: CountryAchievementModel

  var body: some View {
    VStack {
      Image(achievement.country)
        .resizable()
        .scaledToFit()
        .frame(width: 80, height: 60)
        .clipShape(RoundedRectangle(cornerRadius: Spacing.small))
        .overlay {
          if !achievement.isUnlocked {
            RoundedRectangle(cornerRadius: Spacing.small)
              .fill(Color.black.opacity(0.5))
            Image(systemName: "lock.fill")
              .foregroundColor(.secondaryColour)
          }
        }

      Text(achievement.country.displayName)
        .font(.caption)
        .lineLimit(1)
        .minimumScaleFactor(0.5)
    }
    .frame(height: 100)
    .padding(Spacing.small)
    .cornerRadius(Spacing.medium)
  }
}

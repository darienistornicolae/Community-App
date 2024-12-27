import SwiftUI

struct CountryAchievementCell: View {
  let achievement: CountryAchievement

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
              .foregroundColor(.white)
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

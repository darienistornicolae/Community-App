import SwiftUI

struct AchievementsView: View {
  @StateObject private var viewModel = AchievementsViewModel()
  @State private var selectedCountry: CountryAchievementModel?

  let columns = [
    GridItem(.adaptive(minimum: 100), spacing: Spacing.default)
  ]

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(spacing: Spacing.large) {
          VStack(spacing: Spacing.small) {
            Text("\(viewModel.unlockedCount) of \(viewModel.totalCount)")
              .font(.title2)
              .bold()
              .background(Color(.primaryColour))
            
            ProgressView(value: viewModel.progressPercentage)
              .tint(.accentColour)
              .padding(.horizontal)
              .background(Color(.primaryColour))
            
            Text("Countries Unlocked")
              .foregroundColor(.accentColour)
              .background(Color(.primaryColour))
          }
          .padding()
          .background(Color(.primaryColour))

          LazyVGrid(columns: columns, spacing: Spacing.default) {
            ForEach(viewModel.allCountries) { country in
              CountryAchievementCell(achievement: country)
                .onTapGesture {
                  if !country.isUnlocked {
                    selectedCountry = country
                  }
                }
            }
          }
          .background(Color(.primaryColour))
          .padding()
        }
      }
      .background(Color(.primaryColour))
      .navigationTitle("Countries")
    }
  }
}

#Preview {
  AchievementsView()
}

import Foundation
import SwiftUI

struct CountryAchievement: Identifiable, Equatable {
  let id = UUID()
  let country: Asset
  var isUnlocked: Bool
  var unlockedDate: Date?
  
  static func == (lhs: CountryAchievement, rhs: CountryAchievement) -> Bool {
    lhs.id == rhs.id
  }
}

enum Nationality: String, CaseIterable {
  case american = "American"
  case british = "British"
  case canadian = "Canadian"
  case australian = "Australian"
  case german = "German"
  case french = "French"
  case italian = "Italian"
  case spanish = "Spanish"
  case japanese = "Japanese"
  case chinese = "Chinese"
  case indian = "Indian"
  case brazilian = "Brazilian"
  case mexican = "Mexican"
  case russian = "Russian"
  case korean = "Korean"
  case dutch = "Dutch"
  case swedish = "Swedish"
  case norwegian = "Norwegian"
  case danish = "Danish"
  case finnish = "Finnish"
  case irish = "Irish"
  case portuguese = "Portuguese"
  case greek = "Greek"
  case turkish = "Turkish"
  case polish = "Polish"
  case ukrainian = "Ukrainian"
  case romanian = "Romanian"
  case hungarian = "Hungarian"
  case czech = "Czech"
  case slovak = "Slovak"
  case swiss = "Swiss"
  case austrian = "Austrian"
  case belgian = "Belgian"
  case newZealander = "New Zealander"
  case southAfrican = "South African"
  case argentinian = "Argentinian"
  case chilean = "Chilean"
  case colombian = "Colombian"
  case peruvian = "Peruvian"
  case venezuelan = "Venezuelan"
  case egyptian = "Egyptian"
  case moroccan = "Moroccan"
  case nigerian = "Nigerian"
  case kenyan = "Kenyan"
  case israeli = "Israeli"
  case saudi = "Saudi"
  case emirati = "Emirati"
  case iranian = "Iranian"
  case pakistani = "Pakistani"
  case thai = "Thai"
  case vietnamese = "Vietnamese"
  case malaysian = "Malaysian"
  case indonesian = "Indonesian"
  case filipino = "Filipino"
  case singaporean = "Singaporean"
}

struct UserModel {
  var id: Int
  var name: String
  var email: String
  var nationality: Nationality
  var location: String
  var bio: String
  var profileImage: UIImage?
  var unlockedCountries: [CountryAchievement] = []
  
  // Helper method to check if a country is unlocked
  func hasUnlockedCountry(_ country: Asset) -> Bool {
      unlockedCountries.contains { $0.country == country && $0.isUnlocked }
  }
  
  // Helper method to get unlock date for a country
  func getUnlockDate(for country: Asset) -> Date? {
      unlockedCountries.first { $0.country == country }?.unlockedDate
  }
  
  mutating func unlockCountry(_ country: Asset) {
      if !hasUnlockedCountry(country) {
          let achievement = CountryAchievement(
              country: country,
              isUnlocked: true,
              unlockedDate: Date()
          )
          unlockedCountries.append(achievement)
      }
  }
}

import Foundation
import SwiftUI

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
}

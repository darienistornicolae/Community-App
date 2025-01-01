import SwiftUI

enum Asset: String, Equatable, CaseIterable, Codable {
  case afghanistanFlag = "Afghanistan"
  case albaniaFlag = "Albania"
  case andorraFlag = "Andorra"
  case austriaFlag = "Austria"
  case bahrainFlag = "Bahrain"
  case belarusFlag = "Belarus"
  case belgiumFlag = "Belgium"
  case bosniaAndHerzegovinaFlag = "Bosnia_and_Herzegovina"
  case bulgariaFlag = "Bulgaria"
  case croatiaFlag = "Croatia"
  case cyprusFlag = "Cyprus"
  case czechRepublicFlag = "Czech_Republic"
  case denmarkFlag = "Denmark"
  case estoniaFlag = "Estonia"
  case finlandFlag = "Finland"
  case franceFlag = "France"
  case germanyFlag = "Germany"
  case greeceFlag = "Greece"
  case hungaryFlag = "Hungary"
  case icelandFlag = "Iceland"
  case iranFlag = "Iran"
  case iraqFlag = "Iraq"
  case irelandFlag = "Ireland"
  case israelFlag = "Israel"
  case italyFlag = "Italy"
  case jordanFlag = "Jordan"
  case kazakhstanFlag = "Kazakhstan"
  case kuwaitFlag = "Kuwait"
  case kosovoFlag = "Kosovo"
  case latviaFlag = "Latvia"
  case lebanonFlag = "Lebanon"
  case lithuaniaFlag = "Lithuania"
  case maltaFlag = "Malta"
  case moldovaFlag = "Moldova"
  case montenegroFlag = "Montenegro"
  case netherlandsFlag = "the_Netherlands"
  case northMacedoniaFlag = "North_Macedonia"
  case norwayFlag = "Norway"
  case omanFlag = "Oman"
  case polandFlag = "Poland"
  case portugalFlag = "Portugal"
  case qatarFlag = "Qatar"
  case romaniaFlag = "Romania"
  case russiaFlag = "Russia"
  case saudiArabiaFlag = "Saudi_Arabia"
  case serbiaFlag = "Serbia"
  case slovakiaFlag = "Slovakia"
  case sloveniaFlag = "Slovenia"
  case spainFlag = "Spain"
  case swedenFlag = "Sweden"
  case switzerlandFlag = "Switzerland"
  case syriaFlag = "Syria"
  case turkeyFlag = "Turkey"
  case ukraineFlag = "Ukraine"
  case unitedArabEmiratesFlag = "United_Arab_Emirates"
  case unitedKingdomFlag = "United_Kingdom"
  case yemenFlag = "Yemen"

  var displayName: String {
    rawValue
      .replacingOccurrences(of: "_", with: " ")
      .replacingOccurrences(of: "the ", with: "")
  }
}

extension Image {
  init(_ asset: Asset) {
    self.init(asset.rawValue)
  }
}

extension Image {
  init<T: RawRepresentable>(_ asset: T) where T.RawValue == String {
    self.init(asset.rawValue)
  }
}

extension Image {
  static let afghanistanFlag = Image(.afghanistanFlag)
  static let albaniaFlag = Image(.albaniaFlag)
  static let andorraFlag = Image(.andorraFlag)
  static let austriaFlag = Image(.austriaFlag)
  static let bahrainFlag = Image(.bahrainFlag)
  static let belarusFlag = Image(.belarusFlag)
  static let belgiumFlag = Image(.belgiumFlag)
  static let bosniaAndHerzegovinaFlag = Image(.bosniaAndHerzegovinaFlag)
  static let bulgariaFlag = Image(.bulgariaFlag)
  static let croatiaFlag = Image(.croatiaFlag)
  static let cyprusFlag = Image(.cyprusFlag)
  static let czechRepublicFlag = Image(.czechRepublicFlag)
  static let denmarkFlag = Image(.denmarkFlag)
  static let estoniaFlag = Image(.estoniaFlag)
  static let finlandFlag = Image(.finlandFlag)
  static let franceFlag = Image(.franceFlag)
  static let germanyFlag = Image(.germanyFlag)
  static let greeceFlag = Image(.greeceFlag)
  static let hungaryFlag = Image(.hungaryFlag)
  static let icelandFlag = Image(.icelandFlag)
  static let iranFlag = Image(.iranFlag)
  static let iraqFlag = Image(.iraqFlag)
  static let irelandFlag = Image(.irelandFlag)
  static let israelFlag = Image(.israelFlag)
  static let italyFlag = Image(.italyFlag)
  static let jordanFlag = Image(.jordanFlag)
  static let kazakhstanFlag = Image(.kazakhstanFlag)
  static let kuwaitFlag = Image(.kuwaitFlag)
  static let kosovoFlag = Image(.kosovoFlag)
  static let latviaFlag = Image(.latviaFlag)
  static let lebanonFlag = Image(.lebanonFlag)
  static let lithuaniaFlag = Image(.lithuaniaFlag)
  static let maltaFlag = Image(.maltaFlag)
  static let moldovaFlag = Image(.moldovaFlag)
  static let montenegroFlag = Image(.montenegroFlag)
  static let netherlandsFlag = Image(.netherlandsFlag)
  static let northMacedoniaFlag = Image(.northMacedoniaFlag)
  static let norwayFlag = Image(.norwayFlag)
  static let omanFlag = Image(.omanFlag)
  static let polandFlag = Image(.polandFlag)
  static let portugalFlag = Image(.portugalFlag)
  static let qatarFlag = Image(.qatarFlag)
  static let romaniaFlag = Image(.romaniaFlag)
  static let russiaFlag = Image(.russiaFlag)
  static let saudiArabiaFlag = Image(.saudiArabiaFlag)
  static let serbiaFlag = Image(.serbiaFlag)
  static let slovakiaFlag = Image(.slovakiaFlag)
  static let sloveniaFlag = Image(.sloveniaFlag)
  static let spainFlag = Image(.spainFlag)
  static let swedenFlag = Image(.swedenFlag)
  static let switzerlandFlag = Image(.switzerlandFlag)
  static let syriaFlag = Image(.syriaFlag)
  static let turkeyFlag = Image(.turkeyFlag)
  static let ukraineFlag = Image(.ukraineFlag)
  static let unitedArabEmiratesFlag = Image(.unitedArabEmiratesFlag)
  static let unitedKingdomFlag = Image(.unitedKingdomFlag)
  static let yemenFlag = Image(.yemenFlag)
}

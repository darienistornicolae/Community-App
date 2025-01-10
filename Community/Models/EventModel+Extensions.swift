import Foundation

extension EventModel {
  var formattedDate: String {
    DateFormatter.eventTime.string(from: date)
  }
  
  var formattedParticipants: String {
    "\(participants.count) participants"
  }
  
  func canJoin(userId: String) -> Bool {
    !participants.contains(userId) && userId != self.userId
  }
  
  func isCreator(userId: String) -> Bool {
    self.userId == userId
  }
  
  func isParticipating(userId: String) -> Bool {
    participants.contains(userId)
  }
}

import Foundation

extension DateFormatter {
  static let eventTime: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
  }()
} 

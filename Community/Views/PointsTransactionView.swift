import Foundation
import SwiftUI

struct PointsTransactionView: View {
  let transactions: [PointsTransaction]

  var body: some View {
    List(transactions, id: \.timestamp) { transaction in
      VStack(alignment: .leading, spacing: Spacing.small) {
        HStack {
          Image(systemName: transaction.amount >= 0 ? "plus.circle.fill" : "minus.circle.fill")
            .foregroundColor(transaction.amount >= 0 ? .green : .red)
          
          VStack(alignment: .leading) {
            Text(transaction.description)
              .font(.headline)
            Text(transaction.type.rawValue.capitalized)
              .font(.caption)
              .foregroundColor(.gray)
          }

          Spacer()

          Text("\(transaction.amount >= 0 ? "+" : "")\(transaction.amount)")
            .bold()
            .foregroundColor(transaction.amount >= 0 ? .green : .red)
        }

        Text(DateFormatter.eventTime.string(from: transaction.timestamp))
          .font(.caption2)
          .foregroundColor(.gray)
      }
      .padding(.vertical, Spacing.extraSmall)
    }
    .navigationTitle("Points History")
    .navigationBarTitleDisplayMode(.inline)
  }
}

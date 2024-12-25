import SwiftUI

struct GridPostsView: View {
  let posts: [String]

  private let columns = [
    GridItem(.flexible(), spacing: 1),
    GridItem(.flexible(), spacing: 1),
    GridItem(.flexible(), spacing: 1)
  ]

  var body: some View {
    LazyVGrid(columns: columns, spacing: 1) {
      ForEach(posts, id: \.self) { post in
        Color.gray
          .aspectRatio(1, contentMode: .fill)
          .overlay(
            Image(systemName: "photo")
              .foregroundColor(.white)
          )
      }
    }
    .listRowInsets(EdgeInsets())
  }
}

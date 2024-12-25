import Foundation
import SwiftUI

struct ProfileImageView: View {
  let image: UIImage?

  var body: some View {
    if let profileImage = image {
      Image(uiImage: profileImage)
        .resizable()
        .scaledToFill()
        .frame(width: 80, height: 80)
        .clipShape(Circle())
    } else {
      Image(systemName: "person.circle.fill")
        .resizable()
        .frame(width: 80, height: 80)
        .foregroundColor(.gray)
    }
  }
}

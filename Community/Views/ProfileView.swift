import SwiftUI
import PhotosUI

struct ProfileView: View {
  @StateObject private var viewModel = ProfileViewModel()

  var body: some View {
    NavigationStack {
      List {
        Section {
          HStack {
            let profileImage = viewModel.user.profileImage
            PhotosPicker(selection: $viewModel.selectedPhoto, matching: .images) {
              ProfileImageView(image: profileImage)
            }

            VStack(alignment: .leading, spacing: Spacing.extraSmall) {
              Text(viewModel.user.name)
                .font(.title2)
                .bold()

              Text(viewModel.user.email)
                .font(.subheadline)
                .foregroundColor(.gray)
            }
            .padding(.leading, Spacing.small)
          }
          .padding(.vertical, Spacing.small)
        }

        Section {
          HStack {
            Image(systemName: "star.circle.fill")
              .foregroundColor(.yellow)
            Text("\(viewModel.currentPoints) points")
              .font(.headline)
          }

          if !viewModel.pointsHistory.isEmpty {
            NavigationLink {
              PointsTransactionView(transactions: viewModel.pointsHistory)
            } label: {
              HStack {
                Image(systemName: "clock.arrow.circlepath")
                  .foregroundColor(.blue)
                Text("Points History")
              }
            }
          }
        }

        Section("Bio") {
          HStack {
            Image(systemName: "location.fill")
              .foregroundColor(.gray)
            Text(viewModel.user.location)
          }

          HStack {
            Image(systemName: "globe")
              .foregroundColor(.gray)
            Text(viewModel.user.nationality.rawValue)
          }

          Text(viewModel.user.bio)
            .padding(.vertical, Spacing.extraSmall)
        }

        Section("Posts") {
          GridPostsView(posts: viewModel.posts)
        }
      }
      .navigationTitle("Profile")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button {
            viewModel.showingSettings = true
          } label: {
            Image(systemName: "gear")
          }
        }
      }
      .fullScreenCover(isPresented: $viewModel.showingSettings) {
        SettingsView()
      }
    }
  }
}

#Preview {
  ProfileView()
}

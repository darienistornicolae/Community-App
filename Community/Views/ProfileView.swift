import SwiftUI
import PhotosUI

struct ProfileView: View {
  @StateObject private var viewModel = ProfileViewModel()

  var body: some View {
    NavigationStack {
      List {
        Section {
          HStack {
            PhotosPicker(selection: $viewModel.selectedPhoto, matching: .images) {
              if let imageUrl = viewModel.user.profileImageUrl {
                AsyncImage(url: URL(string: imageUrl)) { image in
                  image
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.gray.opacity(0.2), lineWidth: 1))
                } placeholder: {
                  ProgressView()
                    .frame(width: 80, height: 80)
                }
              } else {
                Circle()
                  .fill(Color.gray.opacity(0.2))
                  .frame(width: 80, height: 80)
                  .overlay(
                    Image(systemName: "person.crop.circle.fill")
                      .resizable()
                      .padding(15)
                      .foregroundColor(.gray)
                  )
              }
            }
            .overlay(
              Group {
                if viewModel.isUploadingImage {
                  ProgressView()
                    .frame(width: 80, height: 80)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
                }
              }
            )

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

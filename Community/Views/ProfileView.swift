import SwiftUI
import PhotosUI

struct ProfileView: View {
  @StateObject private var viewModel = ProfileViewModel()
  @State private var showingImageEdit = false
  
  var body: some View {
    NavigationStack {
      List {
        profileSection
        pointsSection
        bioSection
        postsSection
      }
      .navigationTitle("Profile")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          settingsButton
        }
      }
      .fullScreenCover(isPresented: $viewModel.showingSettings) {
        SettingsView()
      }
      .sheet(isPresented: $showingImageEdit) {
        ProfileImageEditView(viewModel: viewModel)
      }
    }
  }
}

// MARK: - Profile View Components
private extension ProfileView {
  var profileSection: some View {
    Section {
      HStack {
        profileImageButton
        userInfoView
        Spacer()
      }
      .padding(.vertical, Spacing.small)
    }
  }

  var profileImageButton: some View {
    Button {
      showingImageEdit = true
    } label: {
      Group {
        if let imageUrl = viewModel.user.profileImageUrl {
          CachedAsyncImage(url: imageUrl) { image in
            image
              .resizable()
              .scaledToFill()
              .profileImageStyle(size: 80)
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
                .padding(Spacing.medium)
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
    }
  }
  
  var userInfoView: some View {
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

  var pointsSection: some View {
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
  }
  
  var bioSection: some View {
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
  }

  var postsSection: some View {
    Section("Posts") {
      GridPostsView(posts: viewModel.posts)
    }
  }

  var settingsButton: some View {
    Button {
      viewModel.showingSettings = true
    } label: {
      Image(systemName: "gear")
    }
  }
}

// MARK: - View Modifiers
private extension View {
  func profileImageStyle(size: CGFloat = 180) -> some View {
    self
      .frame(width: size, height: size)
      .clipShape(Circle())
      .overlay(Circle().stroke(Color.gray.opacity(0.2), lineWidth: Spacing.halfPointSmall))
      .shadow(color: .black.opacity(0.1), radius: Spacing.small, x: 0, y: Spacing.extraSmall)
  }
}

#Preview {
  ProfileView()
}

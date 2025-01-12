import SwiftUI
import PhotosUI

private enum PresentationItem: Identifiable {
  case imageEdit
  case pointsHistory([PointsTransaction])
  case settings
  
  var id: String {
    switch self {
    case .imageEdit:
      return "imageEdit"
    case .pointsHistory:
      return "pointsHistory"
    case .settings:
      return "settings"
    }
  }
}

struct ProfileView: View {
  @StateObject private var viewModel = ProfileViewModel()
  @State private var presentationItem: PresentationItem?

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
      .fullScreenCover(item: $presentationItem) { item in
        switch item {
        case .imageEdit:
          ProfileImageEditView(viewModel: viewModel)
        case .pointsHistory(let transactions):
          PointsTransactionView(transactions: transactions)
        case .settings:
          SettingsView()
        }
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
      presentationItem = .imageEdit
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
        Button {
          presentationItem = .pointsHistory(viewModel.pointsHistory)
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
      presentationItem = .settings
    } label: {
      Image(systemName: "gear")
    }
  }
}

#Preview {
  ProfileView()
}

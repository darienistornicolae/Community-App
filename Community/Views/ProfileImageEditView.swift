import SwiftUI

private enum ImageViewType: Identifiable {
  case imagePicker(UIImagePickerController.SourceType)
  
  var id: String {
    switch self {
    case .imagePicker(let sourceType):
      return "imagePicker-\(sourceType.rawValue)"
    }
  }
}

struct ProfileImageEditView: View {
  @ObservedObject var viewModel: ProfileViewModel
  @StateObject private var cameraPermission = CameraPermissionManager()
  @Environment(\.dismiss) private var dismiss
  @State private var selectedImageData: Data?
  @State private var bottomSheet: ImageViewType?

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(spacing: Spacing.extraLarge) {
          ImagePreviewSection(
            selectedImageData: selectedImageData,
            profileImageUrl: viewModel.user.profileImageUrl,
            isUploading: viewModel.isUploadingImage
          )

          GuidelinesSection()

          ActionButtonsSection(
            selectedImageData: $selectedImageData,
            bottomSheet: $bottomSheet,
            cameraPermission: cameraPermission
          )
        }
      }
      .navigationTitle("Edit Profile Photo")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar { toolbarButtons }
      .sheet(item: $bottomSheet) { sheet in
        switch sheet {
        case .imagePicker(let sourceType):
          ImagePicker(selectedImage: $selectedImageData, sourceType: sourceType)
        }
      }
      .alert("Camera Access Required", isPresented: $cameraPermission.showPermissionError) {
        Button("Cancel", role: .cancel) { }
        Button("Settings") {
          if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
          }
        }
      } message: {
        Text(cameraPermission.errorMessage ?? "Please allow camera access in Settings to take photos.")
      }
      .task {
        await cameraPermission.checkCurrentCameraStatus()
      }
    }
  }

  private var toolbarButtons: some ToolbarContent {
    Group {
      ToolbarItem(placement: .cancellationAction) {
        Button("Cancel") {
          dismiss()
        }
      }
      ToolbarItem(placement: .confirmationAction) {
        Button("Save") {
          if let imageData = selectedImageData {
            Task {
              await viewModel.uploadProfileImage(imageData)
            }
          }
          dismiss()
        }
        .disabled(selectedImageData == nil)
      }
    }
  }
}

private struct ImagePreviewSection: View {
  let selectedImageData: Data?
  let profileImageUrl: String?
  let isUploading: Bool

  var body: some View {
    VStack(spacing: Spacing.medium) {
      ZStack {
        Group {
          if let imageData = selectedImageData,
             let uiImage = UIImage(data: imageData) {
            Image(uiImage: uiImage)
              .resizable()
              .scaledToFill()
              .profileImageStyle(size: 180)
          } else if let imageUrl = profileImageUrl {
            CachedAsyncImage(url: imageUrl) { image in
              image
                .resizable()
                .scaledToFill()
                .profileImageStyle(size: 180)
            } placeholder: {
              ProgressView()
                .frame(width: 180, height: 180)
            }
          } else {
            defaultProfileImage
          }
        }
        .overlay {
          if isUploading {
            uploadingOverlay
          }
        }
      }

      Text(selectedImageData != nil ? "Preview" : "Current Photo")
        .font(.headline)
        .foregroundColor(.gray)
    }
    .padding(.top, Spacing.extraLarge)
  }
  
  var defaultProfileImage: some View {
    Circle()
      .fill(Color.gray.opacity(0.2))
      .frame(width: 180, height: 180)
      .overlay(
        Image(systemName: "person.crop.circle.fill")
          .resizable()
          .padding(40)
          .foregroundColor(.gray)
      )
      .shadow(color: .black.opacity(0.1), radius: Spacing.small, x: 0, y: Spacing.extraSmall)
  }

  var uploadingOverlay: some View {
    ProgressView()
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(.ultraThinMaterial)
      .clipShape(Circle())
  }
}


private struct GuidelinesSection: View {
  var body: some View {
    VStack(spacing: Spacing.medium) {
      Text("Profile Photo Guidelines")
        .font(.headline)
        .padding(.bottom, Spacing.small)

      VStack(alignment: .leading, spacing: Spacing.medium) {
        GuidelineRow(icon: "person.crop.circle", text: "Clear face photo")
        GuidelineRow(icon: "light.max", text: "Good lighting")
        GuidelineRow(icon: "photo.fill", text: "High quality image")
        GuidelineRow(icon: "square.fill", text: "Square format recommended")
      }
      .padding(.horizontal, Spacing.extraExtraLarge)
    }
    .padding()
    .background(Color(.systemGroupedBackground))
    .clipShape(RoundedRectangle(cornerRadius: Spacing.medium))
    .padding(.horizontal)
  }
}

// MARK: - Action Buttons Section
private struct ActionButtonsSection: View {
  @Binding var selectedImageData: Data?
  @Binding var bottomSheet: ImageViewType?
  @ObservedObject var cameraPermission: CameraPermissionManager

  var body: some View {
    VStack(spacing: Spacing.medium) {
      cameraButton
      photoLibraryButton
      if selectedImageData != nil {
        removePhotoButton
      }
    }
    .padding(.horizontal)
  }

  var cameraButton: some View {
    Button {
      Task {
        await cameraPermission.requestCameraPermission()
        if cameraPermission.permissionGranted {
          bottomSheet = .imagePicker(.camera)
        }
      }
    } label: {
      ActionButtonLabel(
        icon: "camera.fill",
        text: "Take Photo",
        color: .blue
      )
    }
  }

  var photoLibraryButton: some View {
    Button {
      bottomSheet = .imagePicker(.photoLibrary)
    } label: {
      ActionButtonLabel(
        icon: "photo.fill",
        text: "Choose from Library",
        color: .blue
      )
    }
  }

  var removePhotoButton: some View {
    Button {
      selectedImageData = nil
    } label: {
      ActionButtonLabel(
        icon: "xmark.circle.fill",
        text: "Remove Selected Photo",
        color: .red,
        style: .outline
      )
    }
  }
}

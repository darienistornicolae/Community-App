import SwiftUI
import AVFoundation

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
  @Environment(\.dismiss) private var dismiss
  @State private var selectedImageData: Data?
  @State private var bottomSheet: ImageViewType?
  @State private var showingCameraPermissionAlert = false

  var body: some View {
    NavigationStack {
      ScrollView {
        VStack(spacing: Spacing.extraLarge) {
          VStack(spacing: Spacing.medium) {
            ZStack {
              Group {
                if let imageData = selectedImageData,
                   let uiImage = UIImage(data: imageData) {
                  Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .profileImageStyle(size: 180)
                } else if let imageUrl = viewModel.user.profileImageUrl {
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
              }
              .overlay {
                if viewModel.isUploadingImage {
                  ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
                }
              }
            }

            Text(selectedImageData != nil ? "Preview" : "Current Photo")
              .font(.headline)
              .foregroundColor(.gray)
          }
          .padding(.top, Spacing.extraLarge)

          VStack(spacing: Spacing.medium) {
            Button {
              checkCameraPermissionAndPresent()
            } label: {
              HStack {
                Image(systemName: "camera.fill")
                  .font(.headline)
                Text("Take Photo")
                  .font(.headline)
              }
              .foregroundColor(.white)
              .frame(maxWidth: .infinity)
              .padding()
              .background(Color.blue)
              .clipShape(RoundedRectangle(cornerRadius: Spacing.medium))
            }

            Button {
              bottomSheet = .imagePicker(.photoLibrary)
            } label: {
              HStack {
                Image(systemName: "photo.fill")
                  .font(.headline)
                Text("Choose from Library")
                  .font(.headline)
              }
              .foregroundColor(.white)
              .frame(maxWidth: .infinity)
              .padding()
              .background(Color.blue)
              .clipShape(RoundedRectangle(cornerRadius: Spacing.medium))
            }

            if selectedImageData != nil {
              Button {
                selectedImageData = nil
              } label: {
                HStack {
                  Image(systemName: "xmark.circle.fill")
                    .font(.headline)
                  Text("Remove Selected Photo")
                    .font(.headline)
                }
                .foregroundColor(.red)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.red.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: Spacing.medium))
              }
            }
          }
          .padding(.horizontal)

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
      .navigationTitle("Edit Profile Photo")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
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
      .sheet(item: $bottomSheet) { sheet in
        switch sheet {
        case .imagePicker(let sourceType):
          ImagePicker(selectedImage: $selectedImageData, sourceType: sourceType)
        }
      }
      .alert("Camera Access Required", isPresented: $showingCameraPermissionAlert) {
        Button("Cancel", role: .cancel) { }
        Button("Settings") {
          if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
          }
        }
      } message: {
        Text("Please allow camera access in Settings to take photos.")
      }
    }
  }
  
  private func checkCameraPermissionAndPresent() {
    Task {
      switch AVCaptureDevice.authorizationStatus(for: .video) {
      case .authorized:
        await MainActor.run {
          bottomSheet = .imagePicker(.camera)
        }
      case .notDetermined:
        let granted = await AVCaptureDevice.requestAccess(for: .video)
        guard granted else { return }
        
        await MainActor.run {
          bottomSheet = .imagePicker(.camera)
        }
      case .denied, .restricted:
        await MainActor.run {
          showingCameraPermissionAlert = true
        }
      @unknown default:
        break
      }
    }
  }
}

private extension View {
  func profileImageStyle(size: CGFloat = 180) -> some View {
    self
      .frame(width: size, height: size)
      .clipShape(Circle())
      .overlay(Circle().stroke(Color.gray.opacity(0.2), lineWidth: Spacing.halfPointSmall))
      .shadow(color: .black.opacity(0.1), radius: Spacing.small, x: 0, y: Spacing.extraSmall)
  }
}

struct ImagePicker: UIViewControllerRepresentable {
  @Binding var selectedImage: Data?
  let sourceType: UIImagePickerController.SourceType
  @Environment(\.dismiss) private var dismiss

  func makeUIViewController(context: Context) -> UIImagePickerController {
    let picker = UIImagePickerController()
    picker.sourceType = sourceType
    picker.delegate = context.coordinator

    if sourceType == .camera {
      picker.cameraCaptureMode = .photo
      picker.cameraDevice = .front
      picker.allowsEditing = true
    }
    return picker
  }
  
  func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
  
  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
  
  class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let parent: ImagePicker
    
    init(_ parent: ImagePicker) {
      self.parent = parent
    }
    
    func imagePickerController(
      _ picker: UIImagePickerController,
      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
      let image = (info[.editedImage] as? UIImage) ?? (info[.originalImage] as? UIImage)
      if let image = image,
         let imageData = image.jpegData(compressionQuality: 0.8) {
        parent.selectedImage = imageData
      }
      parent.dismiss()
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
      parent.dismiss()
    }
  }
}

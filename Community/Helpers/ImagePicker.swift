import SwiftUI
import AVFoundation

struct ImagePicker: UIViewControllerRepresentable {
  @Binding var selectedImage: Data?
  @Environment(\.dismiss) var dismiss
  let sourceType: UIImagePickerController.SourceType

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

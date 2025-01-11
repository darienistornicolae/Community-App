import SwiftUI
import PhotosUI

struct GuidelineRow: View {
  let icon: String
  let text: String
  
  var body: some View {
    HStack(spacing: Spacing.medium) {
      Image(systemName: icon)
        .font(.system(size: 24))
        .foregroundColor(.blue)
        .frame(width: Spacing.extraExtraLarge)
      
      Text(text)
        .font(.subheadline)
    }
  }
}

struct ProfileImageEditView: View {
  @ObservedObject var viewModel: ProfileViewModel
  @Environment(\.dismiss) private var dismiss
  @State private var selectedItem: PhotosPickerItem?
  @State private var selectedImageData: Data?
  
  var body: some View {
    NavigationStack {
      VStack {
        VStack(spacing: Spacing.medium) {
          ZStack {
            if let imageData = selectedImageData,
               let uiImage = UIImage(data: imageData) {
              Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .frame(width: 180, height: 180)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.gray.opacity(0.2), lineWidth: Spacing.halfPointSmall))
                .shadow(color: .black.opacity(0.1), radius: Spacing.small, x: 0, y: Spacing.extraSmall)
            } else if let imageUrl = viewModel.user.profileImageUrl {
              CachedAsyncImage(url: imageUrl) { image in
                image
                  .resizable()
                  .scaledToFill()
                  .frame(width: 180, height: 180)
                  .clipShape(Circle())
                  .overlay(Circle().stroke(Color.gray.opacity(0.2), lineWidth: Spacing.halfPointSmall))
                  .shadow(color: .black.opacity(0.1), radius: Spacing.small, x: 0, y: Spacing.extraSmall)
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

            VStack {
              Spacer()
              HStack {
                Spacer()
                PhotosPicker(selection: $selectedItem, matching: .images) {
                  Image(systemName: "camera.circle.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(.blue)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.2), radius: Spacing.extraSmall, x: 0, y: Spacing.extraExtraSmall)
                }
              }
              .offset(x: -Spacing.small, y: -Spacing.small)
            }
          }
          .padding(.top, Spacing.extraExtraLarge)

          Text(selectedImageData != nil ? "Preview" : "Current Photo")
            .font(.headline)
            .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .background(Color(.systemGroupedBackground))

        VStack(spacing: Spacing.medium) {
          Text("Profile Photo Guidelines")
            .font(.headline)
            .padding(.top, Spacing.extraLarge)

          VStack(alignment: .leading, spacing: Spacing.small) {
            GuidelineRow(icon: "person.crop.circle", text: "Clear face photo")
            GuidelineRow(icon: "light.max", text: "Good lighting")
            GuidelineRow(icon: "photo.fill", text: "High quality image")
          }
          .padding(.horizontal, Spacing.extraExtraLarge)
        }

        Spacer()

        VStack(spacing: Spacing.medium) {
          if selectedImageData != nil {
            Button {
              selectedItem = nil
              selectedImageData = nil
            } label: {
              Text("Remove Selected Photo")
                .foregroundColor(.red)
            }
            .padding(.bottom, Spacing.small)
          }
          
          PhotosPicker(selection: $selectedItem, matching: .images) {
            Text(selectedImageData != nil ? "Choose Different Photo" : "Select New Photo")
              .font(.headline)
              .foregroundColor(.white)
              .frame(maxWidth: .infinity)
              .padding()
              .background(Color.blue)
              .clipShape(RoundedRectangle(cornerRadius: Spacing.medium))
          }
        }
        .padding()
      }
      .onChange(of: selectedItem) { oldValue, newValue in
        Task {
          if let data = try? await newValue?.loadTransferable(type: Data.self) {
            selectedImageData = data
          }
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
            if let item = selectedItem {
              viewModel.selectedPhoto = item
            }
            dismiss()
          }
          .disabled(selectedItem == nil)
        }
      }
    }
  }
}

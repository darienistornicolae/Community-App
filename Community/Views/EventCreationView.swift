import SwiftUI
import PhotosUI

struct EventCreationView: View {
  @Environment(\.dismiss) private var dismiss
  @StateObject private var viewModel = EventCreationViewModel()
  @State private var selectedItem: PhotosPickerItem?
  @State private var selectedImage: UIImage?

  var body: some View {
    NavigationStack {
      Form {
        Section {
          TextField("Event Title", text: $viewModel.title)
          TextField("Location", text: $viewModel.location)
          DatePicker("Date & Time", selection: $viewModel.date, in: Date()...)
        }

        Section("Event Image (Optional)") {
          if let image = selectedImage {
            Image(uiImage: image)
              .resizable()
              .scaledToFit()
              .frame(maxHeight: 200)
              .clipShape(RoundedRectangle(cornerRadius: 12))
            
            Button("Remove Image", role: .destructive) {
              selectedImage = nil
              selectedItem = nil
            }
          } else {
            PhotosPicker(selection: $selectedItem, matching: .images) {
              Label("Add Image", systemImage: "photo")
            }
          }
        }

        Section("Event Description") {
          TextEditor(text: $viewModel.description)
            .frame(height: 100)
        }

        Section {
          Stepper("Entry Price: \(viewModel.price) Points", value: $viewModel.price, in: 0...100, step: 5)
          
          VStack(alignment: .leading, spacing: Spacing.small) {
            Text("Entry price is deducted from participant's points when they join")
              .font(.caption)
              .foregroundColor(.gray)
          }
          .padding(.vertical, Spacing.small)
        }
      }
      .navigationTitle("Create Event")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel") {
            dismiss()
          }
        }

        ToolbarItem(placement: .confirmationAction) {
          Button("Create") {
            Task {
              if let item = selectedItem {
                await viewModel.uploadImage(item)
              }
              await viewModel.createEvent()
              if !viewModel.showError {
                dismiss()
              }
            }
          }
          .disabled(!viewModel.isValid)
        }
      }
      .alert("Error", isPresented: $viewModel.showError) {
        Button("OK", role: .cancel) { }
      } message: {
        Text(viewModel.errorMessage ?? "An unknown error occurred")
      }
      .onChange(of: selectedItem) { oldValue, newValue in
        if let item = newValue {
          Task {
            if let data = try? await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
              selectedImage = image
            }
          }
        }
      }
    }
  }
}

#Preview {
  EventCreationView()
}

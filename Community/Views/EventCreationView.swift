import SwiftUI
import PhotosUI

struct EventCreationView: View {
  @Environment(\.dismiss) private var dismiss
  @StateObject private var viewModel = EventCreationViewModel()
  @State private var selectedItem: PhotosPickerItem?
  
  var body: some View {
    NavigationStack {
      Form {
        Section {
          TextField("Event Title", text: $viewModel.title)
          TextField("Location", text: $viewModel.location)
          DatePicker("Date & Time", selection: $viewModel.date, in: Date()...)
        }
        
        Section("Event Image (Optional)") {
          if let imageUrl = viewModel.imageUrl {
            AsyncImage(url: URL(string: imageUrl)) { image in
              image
                .resizable()
                .scaledToFit()
                .frame(maxHeight: 200)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            } placeholder: {
              RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
                .frame(height: 200)
                .overlay(
                  ProgressView()
                )
            }
            
            Button("Remove Image", role: .destructive) {
              viewModel.imageUrl = nil
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
          Stepper("Entry Price: \(viewModel.price) Points", value: $viewModel.price, in: 0...1000, step: 5)
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
            await viewModel.uploadImage(item)
          }
        }
      }
    }
  }
}

#Preview {
  EventCreationView()
}

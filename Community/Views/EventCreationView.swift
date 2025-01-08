import SwiftUI

struct EventCreationView: View {
  @Environment(\.dismiss) private var dismiss
  @StateObject private var viewModel = EventCreationViewModel()
  
  var body: some View {
    NavigationStack {
      Form {
        Section {
          TextField("Event Title", text: $viewModel.title)
          TextField("Location", text: $viewModel.location)
          DatePicker("Date & Time", selection: $viewModel.date, in: Date()...)
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
              dismiss()
            }
          }
          .disabled(!viewModel.isValid)
        }
      }
    }
  }
}

#Preview {
  EventCreationView()
}

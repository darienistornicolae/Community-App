import SwiftUI
import UIKit

struct EventCreationView: View {
  @State private var eventTitle: String = ""
  @State private var description: String = ""
  @State private var selectedNumber = 1
  @State private var selectedNumbers: [Int] = []
  @State private var showImagePicker = false
  @State private var selectedImage: UIImage?
  
  var body: some View {
    ScrollView{
      VStack {
        Text("Create an Event")
          .font(.largeTitle)
          .fontWeight(.bold)
          .padding()
        
        Button(action: {
          showImagePicker.toggle()
        }) {
          ZStack {
            RoundedRectangle(cornerRadius: 20)
              .stroke(Color.gray, lineWidth: 3)
              .frame(width: 300, height: 300)
            
            if let selectedImage = selectedImage {
              Image(uiImage: selectedImage)
                .resizable()
                .scaledToFit()
                .frame(width: 280, height: 280)
                .clipShape(RoundedRectangle(cornerRadius: 15))
            } else {
              Image(systemName: "plus.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 60, height: 60)
                .foregroundColor(.gray)
            }
          }
          .padding()
        }
        .sheet(isPresented: $showImagePicker) {
          ImagePicker(selectedImage: $selectedImage)
        }
        
        Section(header: Text("Event Details")) {
          TextField("Event Title", text: $eventTitle)
          Text("Description")
            .font(.headline)
          
          TextEditor(text: $description)
            .frame(height: 150) // Adjust height as needed
            .border(Color.gray, width: 0.5)
            .cornerRadius(5)
            .padding(.vertical, 5)
            .padding(.horizontal, 15)
        }
        
        Picker("Event Price", selection: $selectedNumber) {
          ForEach(1...10, id: \.self) { number in
            Text("\(number)")
          }
        }
        .pickerStyle(MenuPickerStyle())
      }
      
      Button(action: {
      }) {
        Text("Save Quiz")
          .foregroundColor(.white)
          .frame(maxWidth: .infinity)
          .padding()
          .background(Color.blue)
          .cornerRadius(10)
      }
      .padding()
    }
  }
}

#Preview {
  EventCreationView()
}

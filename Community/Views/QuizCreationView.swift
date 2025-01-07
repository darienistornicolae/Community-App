import SwiftUI
import UIKit

struct QuizCreationView: View {
  @State private var question: String = ""
  //  @State private var answer1: String = ""
  //  @State private var answer2: String = ""
  //  @State private var answer3: String = ""
  //  @State private var answer4: String = ""
  @State private var answers: [String] = ["", "", "", ""]
  @State private var selectedValues: [Int] = [0, 0, 0, 0]
  @State private var selectedAnswerIndex: Int? = nil
  @State private var showImagePicker = false
  @State private var selectedImage: UIImage?
  
  var body: some View {
    ScrollView{
      VStack {
        Text("Create a Quiz")
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
        Text("Enter the details of your quiz below.")
          .font(.subheadline)
          .foregroundColor(.gray)
          .padding(.bottom, 20)
        
        
        //          Section(header: Text("Quiz Details")) {
        //            TextField("Question", text: $question)
        //            TextField("Answer 1", text: $answer1)
        //            TextField("Answer 2", text: $answer2)
        //            TextField("Answer 3", text: $answer3)
        //            TextField("Answer 4", text: $answer4)
        //          }
        
        Section(header: Text("Quiz Details")) {
          TextField("Question", text: $question)
          
          ForEach(answers.indices, id: \.self) { index in
            HStack {
              TextField("Answer \(index + 1)", text: $answers[index])
              
              Toggle("", isOn: Binding<Bool>(
                get: { selectedValues[index] == 1 },
                set: { isOn in
                  if isOn {
                    // Set the selected value to 1 and reset others to 0
                    selectedValues = [Int](repeating: 0, count: answers.count)
                    selectedValues[index] = 1
                  } else {
                    // Reset the selected value to 0 if toggled off
                    selectedValues[index] = 0
                  }
                }
              ))
              .labelsHidden()
            }
          }
          
          Spacer()
          
          Button(action: {
            // Handle quiz creation logic here
          }) {
            Text("Post Quiz")
              .foregroundColor(.white)
              .frame(maxWidth: .infinity)
              .padding()
              .background(Color.blue)
              .cornerRadius(10)
          }
          .padding()
        }
        .padding()
      }
    }
  }
}
#Preview {
  QuizCreationView()
}

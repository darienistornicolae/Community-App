import SwiftUI

enum SettingsDestination: Hashable {
  case editProfile
  case privacy
  case notifications
  case help
  case about
  case logOut
}

struct SettingsView: View {
  @Environment(\.dismiss) var dismiss
  @State private var destination: SettingsDestination?
  @AppStorage("isShowingLoginScreen") private var isShowingLoginScreen: Bool = false
  
  var body: some View {
    NavigationStack {
      List {
        Section("Account") {
          SettingsRow(
            icon: "person.fill",
            title: "Edit Profile",
            color: .blue,
            action: { destination = .editProfile }
          )
        }

        Section("Support") {
          SettingsRow(
            icon: "questionmark.circle.fill",
            title: "Help",
            color: .blue,
            action: { destination = .help }
          )

          SettingsRow(
            icon: "info.circle.fill",
            title: "About",
            color: .blue,
            action: { destination = .about }
          )
        }

        Section {
          SettingsRow(
            icon: "rectangle.portrait.and.arrow.right",
            title: "Log Out",
            color: .red,
            showNavigation: false,
            action:
              {
              isShowingLoginScreen = false
              }
          )
        }
      }
      .navigationTitle("Settings")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          Button("Done") {
            dismiss()
          }
        }
      }
      .navigationDestination(item: $destination) { destination in
        switch destination {
        case .editProfile:
          Text("Edit Profile")
            .navigationTitle("Edit Profile")
        case .privacy:
          Text("Privacy Settings")
            .navigationTitle("Privacy")
        case .notifications:
          Text("Notification Settings")
            .navigationTitle("Notifications")
        case .help:
          Text("Help Center")
            .navigationTitle("Help")
        case .about:
          Text("About App")
            .navigationTitle("About")
        case .logOut:
          Text("Log Out")
            .navigationTitle("Log Out")
        }
      }
    }
  }
}

#Preview {
  SettingsView()
}

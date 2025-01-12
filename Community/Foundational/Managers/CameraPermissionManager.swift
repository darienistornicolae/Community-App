import Foundation
import AVFoundation
import UIKit

@MainActor
class CameraPermissionManager: ObservableObject {
  @Published var showPermissionError: Bool = false
  @Published var errorMessage: String?
  @Published var permissionGranted: Bool {
    didSet {
      UserDefaults.standard.set(permissionGranted, forKey: "cameraPermissionGranted")
    }
  }

  init() {
    self.permissionGranted = UserDefaults.standard.bool(forKey: "cameraPermissionGranted")
    didBecomeActiveObserver()
  }

  func requestCameraPermission() async {
    do {
      let status = AVCaptureDevice.authorizationStatus(for: .video)
      await handleAuthorizationStatus(status, promptIfNotDetermined: true)
    }
  }

  func checkCurrentCameraStatus() async {
    do {
      let status = AVCaptureDevice.authorizationStatus(for: .video)
      await handleAuthorizationStatus(status, promptIfNotDetermined: false)
    }
  }
}

// MARK: Private
private extension CameraPermissionManager {
  func handleAuthorizationStatus(_ status: AVAuthorizationStatus, promptIfNotDetermined: Bool) async {
    switch status {
    case .notDetermined:
      if promptIfNotDetermined {
        do {
          let granted = try await requestAuthorization()
          await handleAuthorizationResult(.success(granted))
        } catch {
          await handleAuthorizationResult(.failure(error))
        }
      }
    case .denied, .restricted:
      permissionGranted = false
      showPermissionError = true
      errorMessage = "Camera permission was denied. You can enable it in the app settings."
      NotificationCenter.default.post(name: .cameraPermissionStatusChanged, object: nil)

    case .authorized:
      permissionGranted = true
      showPermissionError = false
      errorMessage = nil
      NotificationCenter.default.post(name: .cameraPermissionStatusChanged, object: nil)

    @unknown default:
      showPermissionError = true
      errorMessage = "An unknown error occurred while checking camera permission."
      NotificationCenter.default.post(name: .cameraPermissionStatusChanged, object: nil)
    }
  }

  func handleAuthorizationResult(_ result: Result<Bool, Error>) async {
    switch result {
    case .success(let granted):
      permissionGranted = granted
      if !granted {
        showPermissionError = true
        errorMessage = "Camera permission was denied. You can enable it in the app settings."
        NotificationCenter.default.post(name: .cameraPermissionStatusChanged, object: nil)
      }
    case .failure(let error):
      showPermissionError = true
      errorMessage = "An error occurred while requesting camera permission: \(error.localizedDescription)"
      NotificationCenter.default.post(name: .cameraPermissionStatusChanged, object: nil)
    }
  }

  func requestAuthorization() async throws -> Bool {
    try await withCheckedThrowingContinuation { continuation in
      AVCaptureDevice.requestAccess(for: .video) { granted in
        continuation.resume(returning: granted)
      }
    }
  }

  @objc func appDidBecomeActive() {
    Task {
      await checkCurrentCameraStatus()
    }
  }

  func didBecomeActiveObserver() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(appDidBecomeActive),
      name: UIApplication.didBecomeActiveNotification,
      object: nil
    )
  }
}

extension Notification.Name {
  static let cameraPermissionStatusChanged = Notification.Name("cameraPermissionStatusChanged")
}

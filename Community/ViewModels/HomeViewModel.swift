import Foundation
import SwiftUI
import Combine

@MainActor
class HomeViewModel: ObservableObject {
  @Published private(set) var currentPoints: Int = 0

  private let pointsManager: PointsManagerProtocol
  private let userId: String
  private var cancellables = Set<AnyCancellable>()

  init(
    pointsManager: PointsManagerProtocol? = nil,
    userId: String = UserId.current.rawValue
  ) {
    self.pointsManager = pointsManager ?? PointsManager.shared
    self.userId = userId

    setupPointsObserver()

    Task {
      await self.pointsManager.refreshPoints(for: userId)
    }
  }

  private func setupPointsObserver() {
    guard let observableManager = pointsManager as? PointsManager else { return }

    observableManager.$currentPoints
      .receive(on: RunLoop.main)
      .assign(to: \.currentPoints, on: self)
      .store(in: &cancellables)
  }
}


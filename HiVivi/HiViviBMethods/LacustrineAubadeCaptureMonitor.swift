import Combine
import UIKit

@MainActor
final class LacustrineAubadeCaptureMonitor: ObservableObject {
    @Published private(set) var lacustrineAubadeIsCaptured = false
    private var lacustrineAubadeToken: AnyCancellable?

    func lacustrineAubadeStart() {
        lacustrineAubadeStop()
        lacustrineAubadeRefresh()
        lacustrineAubadeToken = NotificationCenter.default
            .publisher(for: UIScreen.capturedDidChangeNotification)
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.lacustrineAubadeRefresh()
            }
    }

    func lacustrineAubadeStop() {
        lacustrineAubadeToken?.cancel()
        lacustrineAubadeToken = nil
        lacustrineAubadeIsCaptured = false
    }

    private func lacustrineAubadeRefresh() {
        lacustrineAubadeIsCaptured = UIScreen.main.isCaptured
    }
}

import Combine
import Foundation
import Network

@MainActor
final class NetworkMonitor: ObservableObject {
    @Published private(set) var isConnected = true

    private var monitor: NWPathMonitor?
    private let queue = DispatchQueue(label: "Swiftpay.NetworkMonitor")

    init() {
        startMonitoring()
    }

    func refresh() {
        stopMonitoring()
        startMonitoring()
    }

    private func startMonitoring() {
        let monitor = NWPathMonitor()

        monitor.pathUpdateHandler = { [weak self] path in
            let isConnected = path.status == .satisfied
            guard let self else { return }

            Task { @MainActor in
                self.isConnected = isConnected
            }
        }

        monitor.start(queue: queue)
        self.monitor = monitor
    }

    private func stopMonitoring() {
        monitor?.cancel()
        monitor = nil
    }

    deinit {
        monitor?.cancel()
    }
}

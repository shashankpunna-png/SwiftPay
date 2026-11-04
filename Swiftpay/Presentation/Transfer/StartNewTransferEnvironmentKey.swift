import SwiftUI

private struct StartNewTransferKey: EnvironmentKey {
    static let defaultValue: () -> Void = {}
}

extension EnvironmentValues {
    var startNewTransfer: () -> Void {
        get { self[StartNewTransferKey.self] }
        set { self[StartNewTransferKey.self] = newValue }
    }
}

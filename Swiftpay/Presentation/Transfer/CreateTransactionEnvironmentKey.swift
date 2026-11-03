import SwiftUI

private struct CreateTransactionUseCaseKey: EnvironmentKey {
    static let defaultValue: CreateTransactionUseCase? = nil
}

extension EnvironmentValues {

    var createTransactionUseCase: CreateTransactionUseCase? {
        get { self[CreateTransactionUseCaseKey.self] }
        set { self[CreateTransactionUseCaseKey.self] = newValue }
    }
}
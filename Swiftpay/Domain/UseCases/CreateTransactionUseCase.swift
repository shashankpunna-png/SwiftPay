import Foundation

struct CreateTransactionUseCase {
    private let repository: TransactionRepository

    init(repository: TransactionRepository) {
        self.repository = repository
    }

    func execute(
        request: CreateTransactionRequest
    ) async throws -> CreateTransactionResult {
        try await repository.createTransaction(
            request: request
        )
    }
}
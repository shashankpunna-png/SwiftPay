import Foundation

struct RefreshTransactionsUseCase {
    let repository: TransactionRepository

    func execute() async throws {
        try await repository.refreshTransactions()
    }
}
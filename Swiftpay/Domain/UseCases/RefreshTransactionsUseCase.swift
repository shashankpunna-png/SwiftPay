import Foundation

struct RefreshTransactionsUseCase {
    let repository: TransactionRepository

    func execute() async throws -> [Transaction] {
        try await repository.refreshTransactions()
    }
}

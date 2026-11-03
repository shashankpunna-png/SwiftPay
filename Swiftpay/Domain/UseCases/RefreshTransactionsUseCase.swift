import Foundation

struct RefreshTransactionsUseCase {
    let repository: TransactionRepository

    func execute(
        query: TransactionQuery
    ) async throws -> TransactionPage {
        try await repository.refreshTransactions(query: query)
    }
}
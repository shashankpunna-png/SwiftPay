import Foundation

struct GetCachedTransactionsUseCase {
    let repository: TransactionRepository

    func execute(
        query: TransactionQuery
    ) async throws -> [Transaction] {
        try await repository.cachedTransactions(query: query)
    }
}
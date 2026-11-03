import Foundation

protocol TransactionRepository {
    func cachedTransactions(
        query: TransactionQuery
    ) async throws -> [Transaction]

    func refreshTransactions(
        query: TransactionQuery
    ) async throws -> TransactionPage
}
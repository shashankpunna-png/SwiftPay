import Foundation

protocol TransactionRepository {
    func cachedTransactions(
        query: TransactionQuery
    ) async throws -> [Transaction]

    func refreshTransactions(
        query: TransactionQuery
    ) async throws -> TransactionPage

    func createTransaction(
        request: CreateTransactionRequest
    ) async throws -> CreateTransactionResult
}
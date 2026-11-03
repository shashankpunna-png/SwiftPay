import Foundation

protocol TransactionAPI {
    func fetchTransactions(
        query: TransactionQuery
    ) async throws -> TransactionPage
}
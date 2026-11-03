import Foundation

protocol TransactionAPI {
    func fetchTransactions() async throws -> [Transaction]
}
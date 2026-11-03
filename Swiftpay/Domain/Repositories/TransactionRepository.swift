import Foundation

protocol TransactionRepository {
    func cachedTransactions() async throws -> [Transaction]
    func refreshTransactions() async throws -> [Transaction]
}

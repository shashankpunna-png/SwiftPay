import Foundation

final class TransactionRepositoryImpl: TransactionRepository {
    private let remote: TransactionAPI
    private let store: TransactionStore

    init(remote: TransactionAPI, store: TransactionStore) {
        self.remote = remote
        self.store = store
    }

    func cachedTransactions() async throws -> [Transaction] {
        try store.loadTransactions()
    }

    func refreshTransactions() async throws {
        let transactions = try await remote.fetchTransactions()
        try store.saveTransactions(transactions)
    }
}
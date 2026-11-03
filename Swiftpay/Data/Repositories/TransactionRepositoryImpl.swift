
import Foundation

final class TransactionRepositoryImpl: TransactionRepository {

    private let remote: TransactionAPI
    private let store: TransactionStore

    init(
        remote: TransactionAPI,
        store: TransactionStore
    ) {
        self.remote = remote
        self.store = store
    }

    // MARK: - Cached Transactions

    func cachedTransactions(
        query: TransactionQuery
    ) async throws -> [Transaction] {

        try store.loadTransactions(query: query)
    }

    // MARK: - Refresh Transactions

    func refreshTransactions(
        query: TransactionQuery
    ) async throws -> TransactionPage {

        print("Refreshing transactions for query: \(query)")

        // 1. Fetch requested page from API
        let remotePage = try await remote.fetchTransactions(
            query: query
        )

        // 2. Save / upsert response into local database
        try store.saveTransactions(remotePage.transactions)

        // 3. Return pagination metadata
        return remotePage
    }
}

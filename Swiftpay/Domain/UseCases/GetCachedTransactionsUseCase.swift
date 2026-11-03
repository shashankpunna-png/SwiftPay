import Foundation

struct GetCachedTransactionsUseCase {
    let repository: TransactionRepository

    func execute() async throws -> [Transaction] {
        try await repository.cachedTransactions()
    }
}

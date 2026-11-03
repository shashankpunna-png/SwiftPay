import Foundation

struct TransactionRemoteDataSource: TransactionAPI {
    let client: APIClient

    func fetchTransactions() async throws -> [Transaction] {
        let response: TransactionsEnvelope = try await client.send(path: "/api/transactions?limit=50", method: "GET")
        return try response.transactions.map { try $0.domain() }
    }
}

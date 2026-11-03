import Foundation

struct TransactionRemoteDataSource: TransactionAPI {
    let client: APIClient

    func fetchTransactions(
        query: TransactionQuery
    ) async throws -> TransactionPage {

        var queryItems: [URLQueryItem] = [
            URLQueryItem(
                name: "limit",
                value: String(query.limit)
            ),
            URLQueryItem(
                name: "type",
                value: query.type?.rawValue ?? "all"
            )
        ]

        let searchText = query.searchText.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        if !searchText.isEmpty {
            queryItems.append(
                URLQueryItem(name: "q", value: searchText)
            )
        }

        if let fromDate = query.fromDate {
            queryItems.append(
                URLQueryItem(
                    name: "from",
                    value: dateString(fromDate)
                )
            )
        }

        if let toDate = query.toDate {
            queryItems.append(
                URLQueryItem(
                    name: "to",
                    value: dateString(toDate)
                )
            )
        }

        if let cursor = query.cursor {
            queryItems.append(
                URLQueryItem(name: "cursor", value: cursor)
            )
        }

        let response: TransactionsEnvelope = try await client.send(
            path: "/api/transactions",
            method: "GET",
            queryItems: queryItems
        )

        let transactions = try response.transactions.map {
            try $0.domain()
        }

        return TransactionPage(
            transactions: transactions,
            nextCursor: response.pagination.nextCursor,
            hasMore: response.pagination.hasMore,
            total: response.pagination.total
        )
    }

    private func dateString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"

        return formatter.string(from: date)
    }
}
import Foundation

struct TransactionQuery: Sendable {
    let searchText: String
    let type: Transaction.Kind?
    let fromDate: Date?
    let toDate: Date?
    let limit: Int
    let cursor: String?

    static let initial = TransactionQuery(
        searchText: "",
        type: nil,
        fromDate: nil,
        toDate: nil,
        limit: 5,
        cursor: nil
    )
}
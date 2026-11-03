import Foundation

struct TransactionPage: Sendable {
    let transactions: [Transaction]
    let nextCursor: String?
    let hasMore: Bool
    let total: Int
}
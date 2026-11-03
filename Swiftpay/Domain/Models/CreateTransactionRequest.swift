import Foundation

struct CreateTransactionRequest: Equatable, Sendable {
    let amount: Decimal
    let currency: String
    let senderDetails: TransactionParty
    let receiverDetails: TransactionParty
    let idempotencyKey: String
}
import Foundation

struct Transaction: Equatable, Sendable, Identifiable, Hashable {
    enum Kind: String, Equatable, Sendable {
        case credit
        case debit
    }

    enum Status: String, Equatable, Sendable {
        case completed
        case pending
        case cancelled
        case failed
    }

    let id: String
    let type: Kind
    let amount: Decimal
    let currency: String
    let status: Status
    let timestamp: Date
    let fee: Decimal
    let totalAmount: Decimal
    let senderDetails: TransactionParty
    let receiverDetails: TransactionParty
    let errorCode: String?
    let errorMessage: String?

    var isCredit: Bool { type == .credit }
    var isDebit: Bool { type == .debit }
}

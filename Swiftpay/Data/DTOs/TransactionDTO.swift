import Foundation

enum TransactionMappingError: LocalizedError {
    case invalidType(String)
    case invalidStatus(String)
    case invalidTimestamp(String)

    var errorDescription: String? {
        switch self {
        case .invalidType(let value):
            return "Invalid transaction type: \(value)"
        case .invalidStatus(let value):
            return "Invalid transaction status: \(value)"
        case .invalidTimestamp(let value):
            return "Invalid transaction timestamp: \(value)"
        }
    }
}

struct TransactionsEnvelope: Decodable {
    let success: Bool
    let transactions: [TransactionDTO]
    let pagination: TransactionPaginationDTO
}

struct TransactionPaginationDTO: Decodable {
    let nextCursor: String?
    let hasMore: Bool
    let total: Int
}

struct TransactionPartyDTO: Decodable {
    let name: String
    let mobileNumber: String
    let upiId: String

    func domain() -> TransactionParty {
        TransactionParty(name: name, mobileNumber: mobileNumber, upiId: upiId)
    }
}

struct TransactionErrorDTO: Decodable {
    let code: String?
    let message: String?
}

struct TransactionDTO: Decodable {
    let id: String
    let type: String
    let amount: Decimal
    let currency: String
    let status: String
    let timestamp: String
    let fee: Decimal
    let totalAmount: Decimal
    let senderDetails: TransactionPartyDTO
    let receiverDetails: TransactionPartyDTO
    let error: TransactionErrorDTO?

    func domain() throws -> Transaction {
        guard let kind = Transaction.Kind(rawValue: type) else {
            throw TransactionMappingError.invalidType(type)
        }

        guard let statusEnum = Transaction.Status(rawValue: status) else {
            throw TransactionMappingError.invalidStatus(status)
        }

        let formatter = ISO8601DateFormatter()

        formatter.formatOptions = [
            .withInternetDateTime,
            .withFractionalSeconds
        ]

        let date = formatter.date(from: timestamp)
            ?? {
                formatter.formatOptions = [.withInternetDateTime]
                return formatter.date(from: timestamp)
            }()

        guard let date else {
            throw TransactionMappingError.invalidTimestamp(timestamp)
        }

        return Transaction(
            id: id,
            type: kind,
            amount: amount,
            currency: currency,
            status: statusEnum,
            timestamp: date,
            fee: fee,
            totalAmount: totalAmount,
            senderDetails: senderDetails.domain(),
            receiverDetails: receiverDetails.domain(),
            errorCode: error?.code,
            errorMessage: error?.message
        )
    }
}

import Foundation
import SwiftData

@Model
final class StoredTransaction {
    @Attribute(.unique) var id: String

    var type: String
    var amount: Decimal
    var currency: String
    var status: String
    var timestamp: Date
    var fee: Decimal
    var totalAmount: Decimal

    var senderName: String
    var senderMobile: String
    var senderUpi: String

    var receiverName: String
    var receiverMobile: String
    var receiverUpi: String

    var errorCode: String?
    var errorMessage: String?

    init(from transaction: Transaction) {
        id = transaction.id
        type = transaction.type.rawValue
        amount = transaction.amount
        currency = transaction.currency
        status = transaction.status.rawValue
        timestamp = transaction.timestamp
        fee = transaction.fee
        totalAmount = transaction.totalAmount

        senderName = transaction.senderDetails.name
        senderMobile = transaction.senderDetails.mobileNumber
        senderUpi = transaction.senderDetails.upiId

        receiverName = transaction.receiverDetails.name
        receiverMobile = transaction.receiverDetails.mobileNumber
        receiverUpi = transaction.receiverDetails.upiId

        errorCode = transaction.errorCode
        errorMessage = transaction.errorMessage
    }

    // Update an existing database record.
    func update(from transaction: Transaction) {
        type = transaction.type.rawValue
        amount = transaction.amount
        currency = transaction.currency
        status = transaction.status.rawValue
        timestamp = transaction.timestamp
        fee = transaction.fee
        totalAmount = transaction.totalAmount

        senderName = transaction.senderDetails.name
        senderMobile = transaction.senderDetails.mobileNumber
        senderUpi = transaction.senderDetails.upiId

        receiverName = transaction.receiverDetails.name
        receiverMobile = transaction.receiverDetails.mobileNumber
        receiverUpi = transaction.receiverDetails.upiId

        errorCode = transaction.errorCode
        errorMessage = transaction.errorMessage
    }

    // Convert SwiftData model into Domain model.
    func toDomain() throws -> Transaction {
        guard let kind = Transaction.Kind(rawValue: type) else {
            throw TransactionMappingError.invalidType(type)
        }

        guard let statusEnum = Transaction.Status(rawValue: status) else {
            throw TransactionMappingError.invalidStatus(status)
        }

        return Transaction(
            id: id,
            type: kind,
            amount: amount,
            currency: currency,
            status: statusEnum,
            timestamp: timestamp,
            fee: fee,
            totalAmount: totalAmount,
            senderDetails: TransactionParty(
                name: senderName,
                mobileNumber: senderMobile,
                upiId: senderUpi
            ),
            receiverDetails: TransactionParty(
                name: receiverName,
                mobileNumber: receiverMobile,
                upiId: receiverUpi
            ),
            errorCode: errorCode,
            errorMessage: errorMessage
        )
    }
}
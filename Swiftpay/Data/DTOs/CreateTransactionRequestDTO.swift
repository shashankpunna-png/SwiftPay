import Foundation

struct CreateTransactionRequestDTO: Encodable {
    let type: String
    let amount: Decimal
    let currency: String
    let senderDetails: TransactionPartyRequestDTO
    let receiverDetails: TransactionPartyRequestDTO
}

struct TransactionPartyRequestDTO: Encodable {
    let name: String
    let mobileNumber: String
    let upiId: String

    init(domain: TransactionParty) {
        self.name = domain.name
        self.mobileNumber = domain.mobileNumber
        self.upiId = domain.upiId
    }
}
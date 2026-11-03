import Foundation

struct TransactionParty: Equatable, Sendable, Hashable {
    let name: String
    let mobileNumber: String
    let upiId: String
}

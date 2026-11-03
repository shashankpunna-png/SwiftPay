import Foundation

struct CreateTransactionResult: Equatable, Sendable {
    let transaction: Transaction
    let wallet: WalletBalanceChange
}

struct WalletBalanceChange: Equatable, Sendable {
    let currency: String
    let previousBalance: Decimal
    let newBalance: Decimal
}
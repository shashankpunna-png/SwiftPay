import Foundation

struct CreateTransactionResponseDTO: Decodable {
    let success: Bool
    let message: String
    let transaction: TransactionDTO
    let wallet: WalletBalanceDTO

    func domain() throws -> CreateTransactionResult {
        CreateTransactionResult(
            transaction: try transaction.domain(),
            wallet: WalletBalanceChange(
                currency: wallet.currency,
                previousBalance: wallet.previousBalance,
                newBalance: wallet.newBalance
            )
        )
    }
}

struct WalletBalanceDTO: Decodable {
    let currency: String
    let previousBalance: Decimal
    let newBalance: Decimal
}
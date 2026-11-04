import Foundation

struct PaymentReceipt {
    let result: PaymentResult
    let type: Transaction.Kind

    let amount: String
    let dateText: String
    let counterpartyName: String
    let counterpartyDetail: String
    let accountName: String
    let accountDetail: String
    let transactionID: String
    let feeText: String

    // MARK: - Display Properties

    var counterpartyTitle: String {
        type == .credit ? "Received from" : "Paid to"
    }

    var counterpartySymbol: String {
        type == .credit ? "arrow.down.left" : "arrow.up.right"
    }

    var accountTitle: String {
        type == .credit ? "Credited to" : "Debited from"
    }

    var shareText: String {
        """
        SwiftPay Receipt
        \(result.title)

        \(counterpartyTitle): \(counterpartyName)
        Details: \(counterpartyDetail)

        Amount: \(amount)
        Date: \(dateText)
        \(accountTitle): \(accountName) \(accountDetail)
        Transaction ID: \(transactionID)
        Fee: \(feeText)
        """
    }
}

// MARK: - Domain Mapping

extension PaymentReceipt {

    init(transaction: Transaction, accountDetail: String) {
        let isCredit = transaction.type == .credit

        // Identify the other party in the transaction.
        let counterparty = isCredit
            ? transaction.senderDetails
            : transaction.receiverDetails

        // Map Domain status to presentation status.
        let result: PaymentResult

        switch transaction.status {
        case .success:
            result = .success

        case .pending:
            result = .pending

        case .cancelled:
            result = .cancelled
        }

        self.init(
            result: result,
            type: transaction.type,
            amount: Self.formatCurrency(
                transaction.amount,
                currency: transaction.currency
            ),
            dateText: transaction.timestamp.formatted(
                .dateTime
                    .day()
                    .month(.abbreviated)
                    .year()
                    .hour()
                    .minute()
            ),
            counterpartyName: counterparty.name,
            counterpartyDetail: counterparty.upiId.isEmpty
                ? counterparty.mobileNumber
                : counterparty.upiId,
            accountName: "SwiftPay Wallet",
            accountDetail: accountDetail,
            transactionID: transaction.id,
            feeText: Self.formatCurrency(
                transaction.fee,
                currency: transaction.currency
            )
        )
    }
}

// MARK: - Formatting

private extension PaymentReceipt {

    static func formatCurrency(
        _ amount: Decimal,
        currency: String
    ) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = currency
        formatter.locale = Locale(identifier: "en_IN")
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2

        return formatter.string(
            from: NSDecimalNumber(decimal: amount)
        ) ?? "\(currency) \(amount)"
    }
}
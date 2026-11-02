import Foundation

struct PaymentReceipt {
    var result: PaymentResult
    var amount: String
    var dateText: String
    var counterpartyName: String
    var counterpartyDetail: String
    var accountName: String
    var accountDetail: String
    var transactionID: String
    var feeText: String

    static let swiggy = PaymentReceipt(
        result: .debit,
        amount: "₹480.00",
        dateText: "26 Oct 2026, 1:15 PM",
        counterpartyName: "Swiggy",
        counterpartyDetail: "swiggy.orders@swiftpay",
        accountName: "SwiftPay Wallet",
        accountDetail: "Aarav Shah ••3210",
        transactionID: "SP429910482190",
        feeText: "₹0.00"
    )

    static let credit = PaymentReceipt(
        result: .credit,
        amount: "₹1,250.00",
        dateText: "26 Oct 2026, 1:15 PM",
        counterpartyName: "Rohan Verma",
        counterpartyDetail: "rohan@swiftpay",
        accountName: "SwiftPay Wallet",
        accountDetail: "Aarav Shah ••3210",
        transactionID: "SP429910482190",
        feeText: "₹0.00"
    )

    static let processing = PaymentReceipt(
        result: .processing,
        amount: "₹1,200.00",
        dateText: "26 Oct 2026, 1:15 PM",
        counterpartyName: "Swiggy",
        counterpartyDetail: "swiggy.orders@swiftpay",
        accountName: "SwiftPay Wallet",
        accountDetail: "Aarav Shah ••3210",
        transactionID: "SP429910482190",
        feeText: "₹0.00"
    )

    static let cancelled = PaymentReceipt(
        result: .cancelled,
        amount: "₹899.00",
        dateText: "26 Oct 2026, 1:15 PM",
        counterpartyName: "Swiggy",
        counterpartyDetail: "swiggy.orders@swiftpay",
        accountName: "SwiftPay Wallet",
        accountDetail: "Aarav Shah ••3210",
        transactionID: "SP429910482190",
        feeText: "₹0.00"
    )
}

extension PaymentReceipt {
    init(item: TransactionItem, accountDetail: String) {
        self.init(
            result: item.kind == .credit ? .credit : .debit,
            amount: item.amountText,
            dateText: item.dateText,
            counterpartyName: item.title,
            counterpartyDetail: Self.upiID(for: item.title),
            accountName: "SwiftPay Wallet",
            accountDetail: accountDetail,
            transactionID: "SP\(item.id.uuidString.prefix(12))",
            feeText: "₹0.00"
        )
    }

    private static func upiID(for name: String) -> String {
        let slug = name
            .lowercased()
            .replacingOccurrences(of: " ", with: ".")
            .filter { $0.isLetter || $0 == "." }
        return "\(slug)@swiftpay"
    }
}

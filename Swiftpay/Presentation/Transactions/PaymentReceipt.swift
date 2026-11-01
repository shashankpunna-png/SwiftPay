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

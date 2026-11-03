import SwiftUI

enum TransferRoute: Hashable {
    case amount
    case review
    case processing
    case receipt
}

struct TransferFlowView: View {
    @Environment(\.userDetails) private var userDetails
    @State private var path: [TransferRoute] = []
    @State private var name = ""
    @State private var phone = ""
    @State private var upiID = ""
    @State private var amountText = "0"

    private var amount: Decimal {
        Decimal(string: amountText, locale: Locale(identifier: "en_US_POSIX")) ?? 0
    }

    private var fee: Decimal { 0 }
    private var total: Decimal { amount + fee }

    var body: some View {
        NavigationStack(path: $path) {
            RecipientStepView(name: $name, phone: $phone, upiID: $upiID) {
                path.append(.amount)
            }
            .toolbar(.hidden, for: .navigationBar)
            .allowsSwipeBack(false)
            .navigationDestination(for: TransferRoute.self) { route in
                switch route {
                case .amount:
                    AmountStepView(
                        name: name,
                        phone: phone,
                        upiID: upiID,
                        amountText: $amountText
                    ) {
                        path.append(.review)
                    }
                    .allowsSwipeBack(false)
                case .review:
                    ReviewStepView(
                        amount: amount,
                        recipientName: name,
                        recipientPhone: phone,
                        recipientUPI: upiID,
                        walletDetail: userDetails?.user?.accountDetail ?? "",
                        onConfirm: { path.append(.processing) }
                    )
                    .allowsSwipeBack(false)
                case .processing:
                    PaymentProcessingView(
                        recipientName: name,
                        recipientPhone: phone,
                        amountText: money(total),
                        accountDetail: userDetails?.user?.accountDetail ?? "",
                        referenceID: "SP429910482190",
                        onFinished: { showReceipt() }
                    )
                    .allowsSwipeBack(false)
                case .receipt:
                    TransactionDetailView(receipt: receipt)
                }
            }
        }
    }

    private func showReceipt() {
        guard let index = path.lastIndex(of: .processing) else { return }
        path[index] = .receipt
        PaymentFeedback.playSuccess()
    }

    private var receipt: PaymentReceipt {
        PaymentReceipt(
            result: .success,
            type: .debit,
            amount: money(total),
            dateText: Date.now.formatted(
                .dateTime.day().month(.abbreviated).year().hour().minute()
            ),
            counterpartyName: name,
            counterpartyDetail: upiID,
            accountName: "SwiftPay Wallet",
            accountDetail: userDetails?.user?.accountDetail ?? "",
            transactionID: "SP429910482190",
            feeText: money(fee)
        )
    }

    private func money(_ value: Decimal) -> String {
        Self.currency.string(from: value as NSDecimalNumber) ?? "₹0.00"
    }

    private static let currency: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "INR"
        formatter.locale = Locale(identifier: "en_IN")
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()
}

#Preview {
    TransferFlowView()
        .environment(\.userDetails, UserDetailsViewModel.preview)
}

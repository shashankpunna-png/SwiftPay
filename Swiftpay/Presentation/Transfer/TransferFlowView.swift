
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

    @State private var showPaymentError = false
    @State private var paymentErrorMessage = ""

    @StateObject private var viewModel: TransferViewModel

    init(
        createTransaction: CreateTransactionUseCase,
        userDetails: UserDetailsViewModel,
        transactions: TransactionsViewModel
    ) {
        _viewModel = StateObject(
            wrappedValue: TransferViewModel(
                createTransaction: createTransaction,
                userDetails: userDetails,
                transactions: transactions
            )
        )
    }

    private var amount: Decimal {
        Decimal(
            string: amountText,
            locale: Locale(identifier: "en_US_POSIX")
        ) ?? 0
    }

    private var fee: Decimal { 0 }

    private var total: Decimal {
        amount + fee
    }

    var body: some View {
        NavigationStack(path: $path) {
            RecipientStepView(
                name: $name,
                phone: $phone,
                upiID: $upiID
            ) {
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
                        onConfirm: {
                            path.append(.processing)
                        }
                    )
                    .allowsSwipeBack(false)

                case .processing:
                    PaymentProcessingView(
                        recipientName: name,
                        recipientPhone: phone,
                        amountText: money(total),
                        accountDetail: userDetails?.user?.accountDetail ?? ""
                    )
                    .task {
                        await processPayment()
                    }
                    .allowsSwipeBack(false)
                case .receipt:
                    if let receipt {
                        TransactionDetailView(receipt: receipt)
                    } else {
                        ProgressView()
                    }
                }
            }
        }
        .alert(
            "Payment status",
            isPresented: $showPaymentError
        ) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(paymentErrorMessage)
        }
    }

    // MARK: - Payment

    private func processPayment() async {

        let receiver = TransactionParty(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            mobileNumber: phone,
            upiId: upiID.trimmingCharacters(in: .whitespacesAndNewlines)
        )

        await viewModel.submit(
            amount: amount,
            receiver: receiver
        )

        switch viewModel.state {

        case .success:
            guard let index = path.lastIndex(of: .processing) else {
                return
            }

            path[index] = .receipt
            PaymentFeedback.playSuccess()

        case .failure(let message),
             .outcomeUnknown(let message):

            paymentErrorMessage = message
            showPaymentError = true

            if path.last == .processing {
                path.removeLast()
            }

        case .idle, .processing:
            break
        }
    }

    // MARK: - Receipt

    private var receipt: PaymentReceipt? {

        guard case .success(let result) = viewModel.state else {
            return nil
        }

        return PaymentReceipt(
            transaction: result.transaction,
            accountDetail: userDetails?.user?.accountDetail ?? ""
        )
    }

    // MARK: - Formatting

    private func money(_ value: Decimal) -> String {
        Self.currency.string(
            from: NSDecimalNumber(decimal: value)
        ) ?? "₹0.00"
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

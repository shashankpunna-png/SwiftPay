
import SwiftUI

enum TransferRoute: Hashable {
    case amount
    case review(amountText: String)
    case processing
    case receipt
}

struct TransferFlowView: View {

    @Environment(\.userDetails) private var userDetails

    @State private var path: [TransferRoute] = []
    @State private var name = ""
    @State private var phone = ""
    @State private var upiID = ""
    @State private var amountText = ""

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

    private var walletBalance: Decimal {
        userDetails?.user?.walletBalance ?? 0
    }

    private func resetTransferForm() {
        name = ""
        phone = ""
        upiID = ""
        amountText = ""

        viewModel.clearValidationError()
    }

    private func startNewTransfer() {
        resetTransferForm()
        viewModel.resetForNewTransfer()
        path.removeAll()
    }

    var body: some View {
        NavigationStack(path: $path) {
            RecipientStepView(
                name: $name,
                phone: $phone,
                upiID: $upiID,
                validationError: viewModel.validationError
            ) {
                guard viewModel.validateRecipient(
                    name: name,
                    phone: phone,
                    upiID: upiID
                ) else {
                    return
                }

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
                        amountText: $amountText,
                        validationError: viewModel.validationError
                    ) {
                        guard viewModel.validateAmount(
                            amountText: amountText,
                            walletBalance: walletBalance
                        ) else {
                            return
                        }

                        path.append(.review(amountText: amountText))
                    }

                case .review(let enteredAmountText):

                    let reviewAmount = Decimal(
                        string: enteredAmountText,
                        locale: Locale(identifier: "en_US_POSIX")
                    ) ?? 0

                    ReviewStepView(
                        amount: reviewAmount,
                        recipientName: name,
                        recipientPhone: phone,
                        recipientUPI: upiID,
                    walletDetail: userDetails?.user?.accountDetail ?? "",
                    onConfirm: {
                        guard viewModel.validateRecipient(
                            name: name,
                            phone: phone,
                            upiID: upiID
                        ) else {
                            return
                        }

                        guard viewModel.validateAmount(
                            amountText: enteredAmountText,
                            walletBalance: walletBalance
                        ) else {
                            return
                        }

                        path.append(.processing)
                    },
                    validationError: viewModel.validationError
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
                            TransactionDetailView(
                                receipt: receipt,
                                onSendAgain: {
                                    startNewTransfer()
                                }
                            )
                        } else {
                            ProgressView()
                        }
                }
            }
        }
        .onChange(of: name) { _, _ in
            viewModel.clearValidationError()
        }
        .onChange(of: phone) { _, _ in
            viewModel.clearValidationError()
        }
        .onChange(of: upiID) { _, _ in
            viewModel.clearValidationError()
        }
        .onChange(of: amountText) { _, _ in
            viewModel.clearValidationError()
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

            // Clear the previous transfer details.
            resetTransferForm()

            // Keep the receipt visible.
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

import Foundation
import Combine

enum TransferState {
    case idle
    case processing
    case success(CreateTransactionResult)
    case failure(String)
    case outcomeUnknown(String)
}

@MainActor
final class TransferViewModel: ObservableObject {

    // MARK: - UI State

    @Published private(set) var state: TransferState = .idle

    // MARK: - Dependencies

    private let createTransaction: CreateTransactionUseCase
    private let userDetails: UserDetailsViewModel
    private let transactions: TransactionsViewModel

    // MARK: - Payment State

    private var activeIdempotencyKey: String?

    init(
        createTransaction: CreateTransactionUseCase,
        userDetails: UserDetailsViewModel,
        transactions: TransactionsViewModel
    ) {
        self.createTransaction = createTransaction
        self.userDetails = userDetails
        self.transactions = transactions
    }

    // MARK: - Create Payment


    func submit(
    amount: Decimal,
    receiver: TransactionParty
    ) async {

        guard !isProcessing else { return }

        guard amount > 0 else {
            state = .failure("Enter a valid amount.")
            return
        }

        guard let sender = userDetails.user else {
            state = .failure("Unable to load your wallet details.")
            return
        }

        let request = CreateTransactionRequest(
            amount: amount,
            currency: sender.currency,
            senderDetails: TransactionParty(
                name: sender.name,
                mobileNumber: sender.mobileNumber,
                upiId: sender.upiId
            ),
            receiverDetails: receiver,
            idempotencyKey: activeIdempotencyKey ?? UUID().uuidString
        )

        activeIdempotencyKey = request.idempotencyKey
        state = .processing

        do {
            let result = try await createTransaction.execute(
                request: request
            )

            // POST response is the source of truth for payment success.
            state = .success(result)

            // Reconcile local profile and transaction data.
            await refreshAppData()

            activeIdempotencyKey = nil

        } catch {
            // Reconcile even after failure: a timeout may mean
            // the server processed the payment but the response was lost.
            await refreshAppData()

            if isOutcomeUnknown(error) {
                state = .outcomeUnknown(
                    "We couldn't confirm the payment status. Please check your transactions before trying again."
                )
            } else {
                state = .failure(error.localizedDescription)
                activeIdempotencyKey = nil
            }
        }
    }

    private var isProcessing: Bool {
        if case .processing = state {
            return true
        }
        return false
    }

    private func refreshAppData() async {
        async let profileRefresh: Void = userDetails.load()
        async let transactionRefresh: Void = transactions.refreshFromRemote()

        _ = await (profileRefresh, transactionRefresh)
    }

    private func isOutcomeUnknown(_ error: Error) -> Bool {

        guard let apiError = error as? APIError else {
            return true
        }

        switch apiError {
        case .unreachable,
            .timedOut,
            .undecodable:
            return true

        case .server(let status, _, _):
            // A server error can happen after the payment was processed.
            return status >= 500
        }
    }
}
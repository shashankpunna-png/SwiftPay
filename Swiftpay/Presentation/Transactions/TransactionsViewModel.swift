import Foundation
import Combine

@MainActor
final class TransactionsViewModel: ObservableObject {
    @Published private(set) var transactions: [Transaction] = []
    @Published private(set) var isLoading = false
    @Published private(set) var isRefreshing = false
    @Published private(set) var errorMessage: String?

    private let getCached: GetCachedTransactionsUseCase
    private let refresh: RefreshTransactionsUseCase

    private var hasLoaded = false

    init(
        getCached: GetCachedTransactionsUseCase,
        refresh: RefreshTransactionsUseCase
    ) {
        self.getCached = getCached
        self.refresh = refresh
    }

    func load() async {
        guard !hasLoaded else { return }
        hasLoaded = true

        isLoading = true

        do {
            let cached = try await getCached.execute()
            updateTransactions(cached)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false

        await refreshFromRemote()
    }

    func refreshFromRemote() async {
        guard !isRefreshing else { return }

        isRefreshing = true
        defer { isRefreshing = false }

        do {
            try await refresh.execute()

            let updated = try await getCached.execute()
            updateTransactions(updated)

            errorMessage = nil
        } catch {
            if transactions.isEmpty {
                errorMessage = error.localizedDescription
            }
        }
    }

    private func updateTransactions(_ transactions: [Transaction]) {
        self.transactions = transactions.sorted {
            $0.timestamp > $1.timestamp
        }
    }

    // MARK: - Presentation Helpers

    func counterpartyName(for transaction: Transaction) -> String {
        transaction.type == .debit
            ? transaction.receiverDetails.name
            : transaction.senderDetails.name
    }

    func initials(for transaction: Transaction) -> String {
        let words = counterpartyName(for: transaction)
            .split(separator: " ")

        return String(words.prefix(2).compactMap(\.first)).uppercased()
    }

    func formattedDate(for transaction: Transaction) -> String {
        transaction.timestamp.formatted(
            .dateTime.day().month(.abbreviated).hour().minute()
        )
    }

    func formattedAmount(for transaction: Transaction) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = transaction.currency
        formatter.locale = Locale(identifier: "en_IN")
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2

        return formatter.string(
            from: NSDecimalNumber(decimal: transaction.amount)
        ) ?? "\(transaction.currency) \(transaction.amount)"
    }

    func signedAmount(for transaction: Transaction) -> String {
        let amount = formattedAmount(for: transaction)

        return transaction.type == .credit
            ? "+ \(amount)"
            : "− \(amount)"
    }

    func kindTitle(for transaction: Transaction) -> String {
        transaction.type.rawValue.capitalized
    }
}
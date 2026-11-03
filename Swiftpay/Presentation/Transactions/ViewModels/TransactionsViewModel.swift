
import Foundation
import Combine

@MainActor
final class TransactionsViewModel: ObservableObject {

    // MARK: - UI State

    @Published private(set) var transactions: [Transaction] = []
    @Published private(set) var isLoading = false
    @Published private(set) var isRefreshing = false
    @Published private(set) var isLoadingMore = false
    @Published private(set) var hasMore = false
    @Published private(set) var errorMessage: String?

    // MARK: - Dependencies

    private let getCached: GetCachedTransactionsUseCase
    private let refresh: RefreshTransactionsUseCase

    // MARK: - Pagination State

    private var currentQuery = TransactionQuery.initial
    private var nextCursor: String?

    // MARK: - Request State

    private var hasLoaded = false
    private var queryGeneration = 0
    private var activeRefreshID: UUID?

    init(
        getCached: GetCachedTransactionsUseCase,
        refresh: RefreshTransactionsUseCase
    ) {
        self.getCached = getCached
        self.refresh = refresh
    }

    // MARK: - Initial Loading

    func load() async {

        guard !hasLoaded else { return }

        let generation = queryGeneration

        isLoading = true
        defer { isLoading = false }

        do {
            let cached = try await getCached.execute(
                query: currentQuery
            )

            guard generation == queryGeneration else {
                return
            }

            transactions = cached
            hasLoaded = true

        } catch {
            errorMessage = error.localizedDescription
        }

        await refreshFromRemote(
            generation: generation
        )
    }

    // MARK: - Refresh

    func refreshFromRemote() async {

        await refreshFromRemote(
            generation: queryGeneration
        )
    }

    private func refreshFromRemote(
        generation: Int
    ) async {

        guard generation == queryGeneration else {
            return
        }

        let query = currentQuery
        let requestID = UUID()

        activeRefreshID = requestID
        isRefreshing = true

        defer {
            if activeRefreshID == requestID {
                activeRefreshID = nil
                isRefreshing = false
            }
        }

        do {
            // 1. Fetch first page from API
            let page = try await refresh.execute(
                query: query
            )

            // Ignore stale query responses
            guard generation == queryGeneration,
                  activeRefreshID == requestID else {
                return
            }

            // 2. Update pagination metadata
            nextCursor = page.nextCursor
            hasMore = page.hasMore

            // 3. Read updated database records
            let updated = try await getCached.execute(
                query: query
            )

            guard generation == queryGeneration,
                  activeRefreshID == requestID else {
                return
            }

            // 4. Update UI
            transactions = updated
            errorMessage = nil

        } catch {

            guard generation == queryGeneration,
                  activeRefreshID == requestID else {
                return
            }

            if transactions.isEmpty {
                errorMessage = error.localizedDescription
            }
        }
    }

    // MARK: - Pagination

    func loadNextPage() async {

        guard hasMore,
              let cursor = nextCursor,
              !isLoadingMore,
              !isRefreshing else {
            return
        }

        let generation = queryGeneration

        let pageQuery = TransactionQuery(
            searchText: currentQuery.searchText,
            type: currentQuery.type,
            fromDate: currentQuery.fromDate,
            toDate: currentQuery.toDate,
            limit: currentQuery.limit,
            cursor: cursor
        )

        isLoadingMore = true
        defer { isLoadingMore = false }

        do {
            // 1. Fetch next page
            let page = try await refresh.execute(
                query: pageQuery
            )

            // Ignore results from an outdated query
            guard generation == queryGeneration else {
                return
            }

            // 2. Update cursor metadata
            nextCursor = page.nextCursor
            hasMore = page.hasMore

            // 3. Read all matching transactions from database
            let updated = try await getCached.execute(
                query: currentQuery
            )

            guard generation == queryGeneration else {
                return
            }

            // 4. Refresh UI
            transactions = updated
            errorMessage = nil

        } catch {

            guard generation == queryGeneration else {
                return
            }

            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Search and Filters

    func apply(query: TransactionQuery) async {

        // Invalidate previous requests
        queryGeneration += 1

        let generation = queryGeneration

        // Reset active query
        currentQuery = TransactionQuery(
            searchText: query.searchText,
            type: query.type,
            fromDate: query.fromDate,
            toDate: query.toDate,
            limit: query.limit,
            cursor: nil
        )

        // Reset pagination
        nextCursor = nil
        hasMore = false

        // Clear previous error
        errorMessage = nil

        // Load matching cached transactions immediately
        do {
            let cached = try await getCached.execute(
                query: currentQuery
            )

            guard generation == queryGeneration else {
                return
            }

            transactions = cached

        } catch {

            guard generation == queryGeneration else {
                return
            }

            errorMessage = error.localizedDescription
        }

        // Fetch fresh matching transactions
        await refreshFromRemote(
            generation: generation
        )
    }

    // MARK: - Presentation Helpers

    func counterpartyName(
        for transaction: Transaction
    ) -> String {

        transaction.type == .debit
            ? transaction.receiverDetails.name
            : transaction.senderDetails.name
    }

    func initials(
        for transaction: Transaction
    ) -> String {

        let words = counterpartyName(for: transaction)
            .split(separator: " ")

        return String(
            words.prefix(2).compactMap(\.first)
        ).uppercased()
    }

    func formattedDate(
        for transaction: Transaction
    ) -> String {

        transaction.timestamp.formatted(
            .dateTime.day().month(.abbreviated).hour().minute()
        )
    }

    func formattedAmount(
        for transaction: Transaction
    ) -> String {

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

    func signedAmount(
        for transaction: Transaction
    ) -> String {

        let amount = formattedAmount(for: transaction)

        return transaction.type == .credit
            ? "+ \(amount)"
            : "− \(amount)"
    }

    func kindTitle(
        for transaction: Transaction
    ) -> String {

        transaction.type.rawValue.capitalized
    }
}

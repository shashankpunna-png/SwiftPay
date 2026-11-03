
import SwiftUI

struct TransactionsView: View {
    @Environment(\.userDetails) private var userDetails
    @EnvironmentObject private var transactionsViewModel: TransactionsViewModel

    @State private var selectedTransaction: Transaction?

    // Search and filter state
    @State private var searchText = ""
    @State private var selectedFilter: TransactionListFilter = .all
    @State private var selectedDateRange: ClosedRange<Date>?
    @State private var isDateSheetPresented = false

    var body: some View {
        VStack(spacing: 0) {
            AppTopBar()

            VStack(spacing: Theme.Spacing.md) {
                TransactionSearchField(text: $searchText)

                TransactionFilterBar(
                    selection: $selectedFilter,
                    isDateFilterActive: selectedDateRange != nil
                ) {
                    isDateSheetPresented = true
                }
            }
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.top, Theme.Spacing.md)

            ScrollView {
                if transactionsViewModel.transactions.isEmpty {
                    Text(
                        transactionsViewModel.isLoading
                            ? "Loading transactions..."
                            : "No transactions"
                    )
                    .font(Theme.Typography.bodyMedium)
                    .foregroundStyle(Theme.Colors.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding(.top, Theme.Spacing.xl)
                } else {
                    TransactionList(
                        transactions: transactionsViewModel.transactions,
                        isLoadingMore: transactionsViewModel.isLoadingMore,
                        hasMore: transactionsViewModel.hasMore,
                        onSelect: { transaction in
                            selectedTransaction = transaction
                        },
                        onLoadMore: {
                            Task {
                                await transactionsViewModel.loadNextPage()
                            }
                        }
                    )
                    .padding(.horizontal, Theme.Spacing.md)
                    .padding(.top, Theme.Spacing.md)
                    .padding(.bottom, Theme.Spacing.lg)
                }
            }
            .refreshable {
                await transactionsViewModel.refreshFromRemote()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Theme.Colors.background)
        .navigationDestination(item: $selectedTransaction) { transaction in
            TransactionDetailView(
                receipt: PaymentReceipt(
                    transaction: transaction,
                    accountDetail: userDetails?.user?.accountDetail ?? ""
                )
            )
        }
        .sheet(isPresented: $isDateSheetPresented) {
            DateRangeSheet(
                range: selectedDateRange,
                onApply: { range in
                    selectedDateRange = range
                },
                onClear: {
                    selectedDateRange = nil
                }
            )
        }
        .onChange(of: searchText) {
            applyFilters()
        }
        .onChange(of: selectedFilter) {
            applyFilters()
        }
        .onChange(of: selectedDateRange) {
            applyFilters()
        }
        .task {
            await transactionsViewModel.load()
        }
    }

    private func applyFilters() {
        let query = TransactionQuery(
            searchText: searchText,
            type: selectedFilter == .all
                ? nil
                : Transaction.Kind(rawValue: selectedFilter.rawValue.lowercased()),
            fromDate: selectedDateRange?.lowerBound,
            toDate: selectedDateRange?.upperBound,
            limit: 5,
            cursor: nil
        )

        Task {
            await transactionsViewModel.apply(query: query)
        }
    }
}

import SwiftUI

struct TransactionsView: View {
    @State private var query = ""
    @State private var kindFilter = TransactionListFilter.all
    @State private var dateRange: ClosedRange<Date>?
    @State private var isDateSheetPresented = false
    @State private var selectedTransaction: TransactionItem?

    private var filteredTransactions: [TransactionItem] {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        return SampleTransactions.newestFirst.filter { item in
            matches(item, query: trimmedQuery)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            AppTopBar()
            TransactionSearchField(text: $query)
                .padding(.horizontal, Theme.Spacing.md)
                .padding(.top, Theme.Spacing.md)
            TransactionFilterBar(
                selection: $kindFilter,
                isDateFilterActive: dateRange != nil,
                onDateTap: { isDateSheetPresented = true }
            )
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.top, Theme.Spacing.sm)

            ScrollView {
                if filteredTransactions.isEmpty {
                    Text("No transactions")
                        .font(Theme.Typography.bodyMedium)
                        .foregroundStyle(Theme.Colors.textSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(.top, Theme.Spacing.xl)
                } else {
                    TransactionList(transactions: filteredTransactions) { item in
                        selectedTransaction = item
                    }
                        .padding(.horizontal, Theme.Spacing.md)
                        .padding(.top, Theme.Spacing.md)
                        .padding(.bottom, Theme.Spacing.lg)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Theme.Colors.background)
        .navigationDestination(item: $selectedTransaction) { item in
            TransactionDetailView(receipt: PaymentReceipt(item: item))
        }
        .sheet(isPresented: $isDateSheetPresented) {
            DateRangeSheet(range: dateRange) { range in
                dateRange = range
            } onClear: {
                dateRange = nil
            }
        }
    }

    private func matches(_ item: TransactionItem, query: String) -> Bool {
        let matchesQuery = query.isEmpty || item.title.localizedCaseInsensitiveContains(query)
        let matchesKind = switch kindFilter {
        case .all:
            true
        case .credit:
            item.kind == .credit
        case .debit:
            item.kind == .debit
        }
        let matchesDate = dateRange?.contains(item.date) ?? true
        return matchesQuery && matchesKind && matchesDate
    }
}

#Preview {
    TransactionsView()
}

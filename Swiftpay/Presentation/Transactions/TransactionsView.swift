import SwiftUI

struct TransactionsView: View {
    @State private var query = ""
    @State private var kindFilter = TransactionListFilter.all
    @State private var dateRange: ClosedRange<Date>?
    @State private var isDateSheetPresented = false

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
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Theme.Colors.background)
        .sheet(isPresented: $isDateSheetPresented) {
            DateRangeSheet(range: dateRange) { range in
                dateRange = range
            } onClear: {
                dateRange = nil
            }
        }
    }
}

#Preview {
    TransactionsView()
}

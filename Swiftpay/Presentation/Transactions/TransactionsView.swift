import SwiftUI

struct TransactionsView: View {
    @State private var query = ""

    var body: some View {
        VStack(spacing: 0) {
            AppTopBar()
            TransactionSearchField(text: $query)
                .padding(.horizontal, Theme.Spacing.md)
                .padding(.top, Theme.Spacing.md)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Theme.Colors.background)
    }
}

#Preview {
    TransactionsView()
}

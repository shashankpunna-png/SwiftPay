import SwiftUI

struct RecentTransactionsSection: View {
    let transactions: [TransactionItem]
    var onSeeAll: () -> Void = {}
    var onSelect: (TransactionItem) -> Void = { _ in }

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            HStack {
                Text("Recent Transactions")
                    .font(Theme.Typography.headlineSmall)
                    .foregroundStyle(Theme.Colors.neutral)
                Spacer()
                Button(action: onSeeAll) {
                    HStack(spacing: 2) {
                        Text("See all")
                        Image(systemName: "chevron.right")
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .font(Theme.Typography.labelLarge)
                    .foregroundStyle(Theme.Colors.primary)
                }
                .buttonStyle(.plain)
            }

            TransactionList(transactions: transactions, onSelect: onSelect)
        }
        .padding(.horizontal, Theme.Spacing.md)
        .padding(.top, Theme.Spacing.lg)
    }
}

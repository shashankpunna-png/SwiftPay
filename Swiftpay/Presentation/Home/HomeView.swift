import SwiftUI

struct HomeView: View {
    var onSendMoney: () -> Void = {}
    var onShowTransactions: () -> Void = {}

    @State private var isBalanceHidden = false
    @State private var selectedTransaction: TransactionItem?

    private var recentTransactions: [TransactionItem] {
        Array(SampleTransactions.newestFirst.prefix(5))
    }

    var body: some View {
        VStack(spacing: 0) {
            AppTopBar()
            ScrollView {
                VStack(spacing: 0) {
                    HomeGreeting(name: "Aarav", upiID: "aarav.shah@swiftpay")
                    BalanceCard(amount: "₹10,000.00", isHidden: $isBalanceHidden)
                        .padding(.horizontal, Theme.Spacing.md)
                        .padding(.top, Theme.Spacing.sm)

                    HStack(spacing: Theme.Spacing.gutter) {
                        AppButton(title: "Send Money", systemImage: "paperplane.fill", action: onSendMoney)
                        AppButton(
                            title: "Transactions",
                            systemImage: "clock.arrow.circlepath",
                            style: .secondary,
                            action: onShowTransactions
                        )
                    }
                    .padding(.horizontal, Theme.Spacing.md)
                    .padding(.top, Theme.Spacing.md)

                    RecentTransactionsSection(
                        transactions: recentTransactions,
                        onSeeAll: onShowTransactions,
                        onSelect: { selectedTransaction = $0 }
                    )
                }
                .padding(.bottom, Theme.Spacing.lg)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Theme.Colors.background)
        .navigationDestination(item: $selectedTransaction) { item in
            TransactionDetailView(receipt: PaymentReceipt(item: item))
        }
    }
}

#Preview {
    HomeView()
}

import SwiftUI

struct HomeView: View {
    @State private var isBalanceHidden = false

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
                        AppButton(title: "Send Money", systemImage: "paperplane.fill") {}
                        AppButton(
                            title: "Transactions",
                            systemImage: "clock.arrow.circlepath",
                            style: .secondary
                        ) {}
                    }
                    .padding(.horizontal, Theme.Spacing.md)
                    .padding(.top, Theme.Spacing.md)

                    RecentTransactionsSection(transactions: recentTransactions)
                }
                .padding(.bottom, Theme.Spacing.lg)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Theme.Colors.background)
    }
}

#Preview {
    HomeView()
}

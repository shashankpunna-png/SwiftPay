import SwiftUI

struct HomeView: View {
    var onSendMoney: () -> Void = {}
    var onShowTransactions: () -> Void = {}

    @Environment(\.userDetails) private var userDetails
    @EnvironmentObject private var transactionsViewModel: TransactionsViewModel

    @State private var selectedTransaction: Transaction?

    private var user: User? {
        userDetails?.user
    }

    private var recentTransactions: [Transaction] {
        Array(transactionsViewModel.transactions.prefix(5))
    }

    var body: some View {
        VStack(spacing: 0) {
            AppTopBar()

            ScrollView {
                VStack(spacing: 0) {
                    HomeGreeting(
                        name: user?.givenName ?? "",
                        upiID: user?.upiId ?? ""
                    )

                    BalanceCard(
                        amount: user?.formattedBalance ?? "₹0.00",
                        isHidden: hidesBalance
                    )
                    .padding(.horizontal, Theme.Spacing.md)
                    .padding(.top, Theme.Spacing.sm)

                    HStack(spacing: Theme.Spacing.gutter) {
                        AppButton(
                            title: "Send Money",
                            systemImage: "paperplane.fill",
                            action: onSendMoney
                        )

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
        .task {
            await transactionsViewModel.load()
        }
        .navigationDestination(item: $selectedTransaction) { transaction in
          TransactionDetailView(
            receipt: PaymentReceipt(
                transaction: transaction,
                accountDetail: user?.accountDetail ?? ""
            )
         )
        }
    }

    private var hidesBalance: Binding<Bool> {
        Binding(
            get: {
                !(userDetails?.showsBalanceOnLaunch ?? true)
            },
            set: {
                userDetails?.showsBalanceOnLaunch = !$0
            }
        )
    }
}

// #Preview {
//     HomeView()
//         .environment(\.userDetails, UserDetailsViewModel.preview)
//         .environmentObject(TransactionsViewModel.preview)
// }

// static var preview: TransactionsViewModel {
//     let repository = PreviewTransactionRepository()

//     return TransactionsViewModel(
//         getCached: GetCachedTransactionsUseCase(repository: repository),
//         refresh: RefreshTransactionsUseCase(repository: repository)
//     )
// }

// private final class PreviewTransactionRepository: TransactionRepository {
//     func cachedTransactions() async throws -> [Transaction] {
//         []
//     }

//     func refreshTransactions() async throws {
//     }
// }
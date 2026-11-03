
import SwiftUI

struct TransactionsView: View {
    @Environment(\.userDetails) private var userDetails
    @EnvironmentObject private var transactionsViewModel: TransactionsViewModel

    @State private var selectedTransaction: Transaction?

    var body: some View {
        VStack(spacing: 0) {
            AppTopBar()

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
                        transactions: transactionsViewModel.transactions
                    ) { transaction in
                        selectedTransaction = transaction
                    }
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
        .task {
            await transactionsViewModel.load()
        }
    }
}

#Preview {
    let container = DependencyContainer()

    TransactionsView()
        .environment(\.userDetails, container.userDetails)
        .environmentObject(container.transactions)
}
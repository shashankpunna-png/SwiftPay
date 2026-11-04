import SwiftUI

enum AppTab: Hashable {
    case home
    case transfer
    case transactions
}

struct MainTabView: View {
    @State private var selectedTab = AppTab.home
    @State private var showProfile = false
    @State private var transferResetToken = 0
    @Environment(\.userDetails) private var userDetails
    @Environment(\.createTransactionUseCase) private var createTransaction
    @EnvironmentObject private var transactions: TransactionsViewModel

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                HomeView(
                    onSendMoney: { selectedTab = .transfer },
                    onShowTransactions: { selectedTab = .transactions }
                )
                .toolbar(.hidden, for: .navigationBar)
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
            .tag(AppTab.home)

            Group {
                if let userDetails,
                let createTransaction {
                    TransferFlowView(
                        createTransaction: createTransaction,
                        userDetails: userDetails,
                        transactions: transactions
                    )
                    .id(transferResetToken)
                } else {
                    ProgressView()
                }
            }
            .tabItem {
                Label("Transfer", systemImage: "paperplane.fill")
            }
            .tag(AppTab.transfer)

            NavigationStack {
                TransactionsView()
                    .toolbar(.hidden, for: .navigationBar)
            }
            .tabItem {
                Label("Transactions", systemImage: "clock.arrow.circlepath")
            }
            .tag(AppTab.transactions)
        }
        .tint(Theme.Colors.primary)
        .environment(\.openProfile) {
            showProfile = true
        }
        .environment(\.startNewTransfer) {
            transferResetToken += 1
            selectedTab = .transfer
        }
        .fullScreenCover(isPresented: $showProfile) {
            ProfileView()
        }
    }
}

#Preview {
    MainTabView()
        .environment(\.userDetails, UserDetailsViewModel.preview)
}

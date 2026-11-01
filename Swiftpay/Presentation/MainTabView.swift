import SwiftUI

enum AppTab: Hashable {
    case home
    case transfer
    case transactions
}

struct MainTabView: View {
    @State private var selectedTab = AppTab.home

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

            TransferFlowView()
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
    }
}

#Preview {
    MainTabView()
}

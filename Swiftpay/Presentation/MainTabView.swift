import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            NavigationStack {
                HomeView()
                    .toolbar(.hidden, for: .navigationBar)
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }

            TransferFlowView()
                .tabItem {
                    Label("Transfer", systemImage: "paperplane.fill")
                }

            NavigationStack {
                TransactionsView()
                    .toolbar(.hidden, for: .navigationBar)
            }
            .tabItem {
                Label("Transactions", systemImage: "clock.arrow.circlepath")
            }
        }
        .tint(Theme.Colors.primary)
    }
}

#Preview {
    MainTabView()
}

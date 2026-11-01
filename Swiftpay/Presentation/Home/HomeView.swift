import SwiftUI

struct HomeView: View {
    @State private var isBalanceHidden = false

    var body: some View {
        VStack(spacing: 0) {
            AppTopBar()
            HomeGreeting(name: "Aarav", upiID: "aarav.shah@swiftpay")
            BalanceCard(amount: "₹10,000.00", isHidden: $isBalanceHidden)
                .padding(.horizontal, Theme.Spacing.md)
                .padding(.top, Theme.Spacing.sm)

            HStack(spacing: Theme.Spacing.gutter) {
                AppButton(title: "Send Money", systemImage: "paperplane.fill") {}
                AppButton(title: "Transactions", systemImage: "clock.arrow.circlepath", style: .secondary) {}
            }
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.top, Theme.Spacing.md)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Theme.Colors.background)
    }
}

#Preview {
    HomeView()
}

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
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Theme.Colors.background)
    }
}

#Preview {
    HomeView()
}

import SwiftUI

struct TransactionDetailView: View {
    let receipt: PaymentReceipt

    var body: some View {
        VStack(spacing: 0) {
            AppTopBar()

            ScrollView {
                VStack(spacing: Theme.Spacing.md) {
                    PaymentStatusCard(receipt: receipt)
                    PaymentSummaryCard(receipt: receipt)

                    HStack(spacing: Theme.Spacing.gutter) {
                        AppButton(
                            title: "Send again",
                            systemImage: "arrow.clockwise"
                        ) {}

                        AppButton(
                            title: "Share receipt",
                            systemImage: "square.and.arrow.up",
                            style: .secondary
                        ) {}
                    }
                }
                .padding(Theme.Spacing.md)
                .padding(.bottom, Theme.Spacing.lg)
            }
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .top
        )
        .background(Theme.Colors.background)
        .toolbar(.hidden, for: .navigationBar)
        .allowsSwipeBack()
    }
}
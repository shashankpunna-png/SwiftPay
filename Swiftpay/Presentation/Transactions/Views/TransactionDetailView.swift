
import SwiftUI

struct TransactionDetailView: View {
    let receipt: PaymentReceipt
    let onSendAgain: () -> Void

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
                            systemImage: "arrow.clockwise",
                            action: onSendAgain
                        )

                        ShareLink(item: receipt.shareText) {
                            HStack(spacing: Theme.Spacing.sm) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 18, weight: .semibold))
                                    .accessibilityHidden(true)

                                Text("Share receipt")
                                    .font(Theme.Typography.labelLarge)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                            }
                        }
                        .buttonStyle(AppButtonStyle(style: .secondary))
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

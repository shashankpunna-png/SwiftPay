import SwiftUI

struct BalanceCard: View {
    let amount: String
    @Binding var isHidden: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
            HStack {
                Text("Total Wallet Balance")
                    .font(Theme.Typography.labelLarge)
                    .foregroundStyle(Theme.Colors.onPrimary.opacity(0.8))

                Spacer()

                Button {
                    let wasHidden = isHidden
                    isHidden.toggle()
                    if wasHidden {
                        PaymentFeedback.playCoins()
                    }
                } label: {
                    Image(systemName: isHidden ? "eye.slash" : "eye")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(Theme.Colors.onPrimary.opacity(0.9))
                        .frame(width: 32, height: 32)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(isHidden ? "Show balance" : "Hide balance")
            }

            HStack(alignment: .firstTextBaseline, spacing: Theme.Spacing.sm) {
                Text(isHidden ? "₹ ••••••" : amount)
                    .font(Theme.Typography.displayCurrency)
                    .foregroundStyle(Theme.Colors.onPrimary)
                    .accessibilityLabel(isHidden ? "Balance hidden" : amount)

                Text("INR")
                    .font(Theme.Typography.labelSmall)
                    .foregroundStyle(Theme.Colors.onPrimary.opacity(0.7))
            }
        }
        .padding(Theme.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            Theme.Colors.primary,
            in: RoundedRectangle(cornerRadius: Theme.Radius.hero, style: .continuous)
        )
        .shadow(color: Theme.Colors.primary.opacity(0.22), radius: 12, y: 8)
    }
}

private struct BalanceCardPreview: View {
    @State private var isHidden = false

    var body: some View {
        BalanceCard(amount: "₹10,000.00", isHidden: $isHidden)
            .padding(Theme.Spacing.md)
            .background(Theme.Colors.background)
    }
}

#Preview {
    BalanceCardPreview()
}

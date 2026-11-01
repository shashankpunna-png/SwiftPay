import SwiftUI

struct PaymentStatusCard: View {
    let receipt: PaymentReceipt

    var body: some View {
        VStack(spacing: Theme.Spacing.md) {
            PaymentStatusMark(result: receipt.result)

            HStack(spacing: Theme.Spacing.xs) {
                Circle()
                    .fill(receipt.result.color)
                    .frame(width: 8, height: 8)
                Text(receipt.result.title)
                    .font(Theme.Typography.labelSmall)
                    .textCase(.uppercase)
                    .tracking(0.6)
            }
            .foregroundStyle(receipt.result.color)
            .padding(.horizontal, Theme.Spacing.md)
            .padding(.vertical, Theme.Spacing.xs)
            .background(receipt.result.halo, in: Capsule())

            VStack(spacing: Theme.Spacing.xs) {
                Text(receipt.amount)
                    .font(Theme.Typography.displayCurrency)
                    .monospacedDigit()
                    .foregroundStyle(Theme.Colors.neutral)

                HStack(spacing: Theme.Spacing.xs) {
                    Image(systemName: "clock")
                        .font(.system(size: 14, weight: .medium))
                        .accessibilityHidden(true)
                    Text(receipt.dateText)
                        .font(Theme.Typography.bodySmall)
                }
                .foregroundStyle(Theme.Colors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(Theme.Spacing.lg)
        .background(
            Theme.Colors.surface,
            in: RoundedRectangle(cornerRadius: Theme.Radius.hero, style: .continuous)
        )
    }
}

private struct PaymentStatusMark: View {
    let result: PaymentResult

    var body: some View {
        ZStack {
            ForEach(0..<8, id: \.self) { index in
                Circle()
                    .fill(result.halo)
                    .frame(width: 36, height: 36)
                    .offset(y: -28)
                    .rotationEffect(.degrees(Double(index) * 45))
            }

            Circle()
                .fill(result.color)
                .frame(width: 64, height: 64)

            Image(systemName: result.symbol)
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(Theme.Colors.onPrimary)
        }
        .frame(width: 104, height: 104)
        .accessibilityLabel(result.title)
    }
}

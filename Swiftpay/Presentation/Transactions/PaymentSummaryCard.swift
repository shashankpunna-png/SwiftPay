import SwiftUI
import UIKit

struct PaymentSummaryCard: View {
    let receipt: PaymentReceipt

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("Payment summary")
                .font(Theme.Typography.headlineSmall)
                .foregroundStyle(Theme.Colors.neutral)

            PartyRow(
                symbol: receipt.result.counterpartySymbol,
                title: receipt.result.counterpartyTitle,
                name: receipt.counterpartyName,
                detail: receipt.counterpartyDetail,
                trailing: receipt.amount
            )

            Divider().overlay(Theme.Colors.divider)

            PartyRow(
                symbol: "wallet.pass",
                title: receipt.result.accountTitle,
                name: receipt.accountName,
                detail: receipt.accountDetail,
                badge: receipt.result.accountBadge,
                badgeColor: receipt.result.color,
                badgeBackground: receipt.result.halo
            )

            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                CopyableIDRow(title: "Transaction ID", value: receipt.transactionID)

                HStack {
                    Text("Fee & charges")
                        .font(Theme.Typography.bodyMedium)
                        .foregroundStyle(Theme.Colors.textSecondary)
                    Spacer()
                    Text(receipt.feeText)
                        .font(Theme.Typography.labelLarge)
                        .monospacedDigit()
                        .foregroundStyle(Theme.Colors.neutral)
                }
            }
            .padding(Theme.Spacing.md)
            .background(
                Theme.Colors.fieldBackground,
                in: RoundedRectangle(cornerRadius: Theme.Radius.input, style: .continuous)
            )
        }
        .padding(Theme.Spacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            Theme.Colors.surface,
            in: RoundedRectangle(cornerRadius: Theme.Radius.hero, style: .continuous)
        )
    }
}

private struct PartyRow: View {
    let symbol: String
    let title: String
    let name: String
    let detail: String
    var trailing: String?
    var badge: String?
    var badgeColor: Color = Theme.Colors.success
    var badgeBackground: Color = Theme.Colors.successBackground

    var body: some View {
        HStack(alignment: .center, spacing: Theme.Spacing.md) {
            Image(systemName: symbol)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Theme.Colors.primary)
                .frame(width: 44, height: 44)
                .background(Theme.Colors.tertiary)
                .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.input, style: .continuous))
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(Theme.Typography.bodySmall)
                    .foregroundStyle(Theme.Colors.textSecondary)
                Text(name)
                    .font(Theme.Typography.labelLarge)
                    .foregroundStyle(Theme.Colors.neutral)
                    .lineLimit(1)
                Text(detail)
                    .font(Theme.Typography.bodySmall)
                    .foregroundStyle(Theme.Colors.textSecondary)
                    .lineLimit(1)
            }

            Spacer(minLength: Theme.Spacing.sm)

            if let trailing {
                Text(trailing)
                    .font(Theme.Typography.labelLarge)
                    .monospacedDigit()
                    .foregroundStyle(Theme.Colors.neutral)
            }

            if let badge {
                Text(badge)
                    .font(Theme.Typography.labelSmall)
                    .foregroundStyle(badgeColor)
                    .padding(.horizontal, Theme.Spacing.sm)
                    .padding(.vertical, Theme.Spacing.xs)
                    .background(badgeBackground, in: Capsule())
            }
        }
    }
}

private struct CopyableIDRow: View {
    let title: String
    let value: String

    @State private var didCopy = false

    var body: some View {
        HStack(spacing: Theme.Spacing.sm) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(Theme.Typography.bodySmall)
                    .foregroundStyle(Theme.Colors.textSecondary)
                Text(value)
                    .font(Theme.Typography.labelLarge)
                    .monospacedDigit()
                    .foregroundStyle(Theme.Colors.neutral)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }

            Spacer(minLength: Theme.Spacing.sm)

            Button {
                UIPasteboard.general.string = value
                didCopy = true
                Task {
                    try? await Task.sleep(for: .seconds(1.5))
                    didCopy = false
                }
            } label: {
                Image(systemName: didCopy ? "checkmark" : "doc.on.doc")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(didCopy ? Theme.Colors.success : Theme.Colors.primary)
                    .frame(width: 36, height: 36)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(didCopy ? "Copied" : "Copy \(title)")
        }
    }
}

import SwiftUI

struct TransactionRow: View {
    let transaction: Transaction

    @EnvironmentObject private var transactionsViewModel: TransactionsViewModel

    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            Text(transactionsViewModel.initials(for: transaction))
                .font(Theme.Typography.labelLarge)
                .foregroundStyle(tint)
                .frame(width: 44, height: 44)
                .background(tintBackground)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Text(transactionsViewModel.counterpartyName(for: transaction))
                    .font(Theme.Typography.labelLarge)
                    .foregroundStyle(Theme.Colors.neutral)
                    .lineLimit(1)

                Text(transactionsViewModel.formattedDate(for: transaction))
                    .font(Theme.Typography.bodySmall)
                    .foregroundStyle(Theme.Colors.textSecondary)
            }

            Spacer(minLength: Theme.Spacing.sm)

            VStack(alignment: .trailing, spacing: Theme.Spacing.xs) {
                Text(transactionsViewModel.signedAmount(for: transaction))
                    .font(Theme.Typography.labelLarge)
                    .monospacedDigit()
                    .foregroundStyle(tint)

                Text(transactionsViewModel.kindTitle(for: transaction))
                    .font(Theme.Typography.labelSmall)
                    .foregroundStyle(tint)
                    .padding(.horizontal, Theme.Spacing.sm)
                    .padding(.vertical, 2)
                    .background(tintBackground, in: Capsule())
            }
        }
        .padding(.horizontal, Theme.Spacing.md)
        .padding(.vertical, Theme.Spacing.gutter)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            "\(transactionsViewModel.counterpartyName(for: transaction)), " +
            "\(transactionsViewModel.formattedDate(for: transaction)), " +
            "\(transactionsViewModel.signedAmount(for: transaction)), " +
            "\(transactionsViewModel.kindTitle(for: transaction))"
        )
    }

    private var tint: Color {
        switch transaction.type {
        case .credit:
            return Theme.Colors.success
        case .debit:
            return Theme.Colors.error
        }
    }

    private var tintBackground: Color {
        switch transaction.type {
        case .credit:
            return Theme.Colors.successBackground
        case .debit:
            return Theme.Colors.errorBackground
        }
    }
}


struct TransactionList: View {
    let transactions: [Transaction]
    var onSelect: ((Transaction) -> Void)? = nil

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(transactions.enumerated()), id: \.element.id) { index, transaction in
                row(for: transaction)

                if index < transactions.count - 1 {
                    Rectangle()
                        .fill(Theme.Colors.divider)
                        .frame(height: 1)
                        .padding(.horizontal, Theme.Spacing.md)
                }
            }
        }
        .background(
            Theme.Colors.surface,
            in: RoundedRectangle(
                cornerRadius: Theme.Radius.hero,
                style: .continuous
            )
        )
    }

    @ViewBuilder
    private func row(for transaction: Transaction) -> some View {
        if let onSelect {
            Button {
                onSelect(transaction)
            } label: {
                TransactionRow(transaction: transaction)
            }
            .buttonStyle(.plain)
        } else {
            TransactionRow(transaction: transaction)
        }
    }
}
import SwiftUI

struct TransactionRow: View {
    let item: TransactionItem

    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            Text(item.initials)
                .font(Theme.Typography.labelLarge)
                .foregroundStyle(tint)
                .frame(width: 44, height: 44)
                .background(tintBackground)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Text(item.title)
                    .font(Theme.Typography.labelLarge)
                    .foregroundStyle(Theme.Colors.neutral)
                    .lineLimit(1)
                Text(item.dateText)
                    .font(Theme.Typography.bodySmall)
                    .foregroundStyle(Theme.Colors.textSecondary)
            }

            Spacer(minLength: Theme.Spacing.sm)

            VStack(alignment: .trailing, spacing: Theme.Spacing.xs) {
                Text(item.signedAmount)
                    .font(Theme.Typography.labelLarge)
                    .monospacedDigit()
                    .foregroundStyle(tint)
                Text(item.kind.rawValue)
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
        .accessibilityLabel("\(item.title), \(item.dateText), \(item.signedAmount), \(item.kind.rawValue)")
    }

    private var tint: Color {
        switch item.kind {
        case .credit:
            return Theme.Colors.success
        case .debit:
            return Theme.Colors.error
        }
    }

    private var tintBackground: Color {
        switch item.kind {
        case .credit:
            return Theme.Colors.successBackground
        case .debit:
            return Theme.Colors.errorBackground
        }
    }
}

struct TransactionList: View {
    let transactions: [TransactionItem]
    var onSelect: ((TransactionItem) -> Void)? = nil

    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(transactions.enumerated()), id: \.element.id) { index, item in
                row(for: item)
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
            in: RoundedRectangle(cornerRadius: Theme.Radius.hero, style: .continuous)
        )
    }

    @ViewBuilder
    private func row(for item: TransactionItem) -> some View {
        if let onSelect {
            Button {
                onSelect(item)
            } label: {
                TransactionRow(item: item)
            }
            .buttonStyle(.plain)
        } else {
            TransactionRow(item: item)
        }
    }
}

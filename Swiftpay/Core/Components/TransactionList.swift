import SwiftUI

struct TransactionRow: View {
    let transaction: Transaction

    @EnvironmentObject private var transactionsViewModel: TransactionsViewModel

    var body: some View {
        HStack(spacing: Theme.Spacing.md) {
            Text(transactionsViewModel.initials(for: transaction))
                .font(Theme.Typography.labelLarge)
                .foregroundStyle(typeColor)
                .frame(width: 44, height: 44)
                .background(typeBackground)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Text(transactionsViewModel.counterpartyName(for: transaction))
                    .font(Theme.Typography.labelLarge)
                    .foregroundStyle(Theme.Colors.neutral)
                    .lineLimit(1)

                Text(transactionsViewModel.formattedDate(for: transaction))
                    .font(Theme.Typography.bodySmall)
                    .foregroundStyle(Theme.Colors.textSecondary)

                HStack(spacing: Theme.Spacing.xs) {
                    typeBadge
                    statusBadge
                }
            }

            Spacer(minLength: Theme.Spacing.sm)

            Text(transactionsViewModel.signedAmount(for: transaction))
                .font(Theme.Typography.labelLarge)
                .monospacedDigit()
                .foregroundStyle(typeColor)
        }
        .padding(.horizontal, Theme.Spacing.md)
        .padding(.vertical, Theme.Spacing.gutter)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            "\(transactionsViewModel.counterpartyName(for: transaction)), " +
            "\(transactionsViewModel.kindTitle(for: transaction)), " +
            "\(statusTitle), " +
            "\(transactionsViewModel.formattedDate(for: transaction)), " +
            "\(transactionsViewModel.signedAmount(for: transaction))"
        )
    }

    private var typeBadge: some View {
        Text(transactionsViewModel.kindTitle(for: transaction))
            .font(Theme.Typography.labelSmall)
            .foregroundStyle(typeColor)
            .padding(.horizontal, Theme.Spacing.sm)
            .padding(.vertical, 3)
            .background(typeBackground, in: Capsule())
    }

    private var statusBadge: some View {
        Text(statusTitle)
            .font(Theme.Typography.labelSmall)
            .foregroundStyle(statusColor)
            .padding(.horizontal, Theme.Spacing.sm)
            .padding(.vertical, 3)
            .background(statusBackground, in: Capsule())
    }

    private var typeColor: Color {
        switch transaction.type {
        case .credit:
            return Theme.Colors.success
        case .debit:
            return Theme.Colors.error
        }
    }

    private var typeBackground: Color {
        switch transaction.type {
        case .credit:
            return Theme.Colors.successBackground
        case .debit:
            return Theme.Colors.errorBackground
        }
    }

    private var statusTitle: String {
        switch transaction.status {
        case .pending:
            return "Pending"
        case .success:
            return "Success"
        case .cancelled:
            return "Cancelled"
        }
    }

    private var statusColor: Color {
        switch transaction.status {
        case .pending:
            return Theme.Colors.warning
        case .success:
            return Theme.Colors.success
        case .cancelled:
            return Theme.Colors.error
        }
    }

    private var statusBackground: Color {
            switch transaction.status {
            case .pending:
                return Theme.Colors.warningBackground
            case .success:
                return Theme.Colors.successBackground
            case .cancelled:
                return Theme.Colors.errorBackground
            }
    }
}

struct TransactionList: View {
    let transactions: [Transaction]

    var isLoadingMore = false
    var hasMore = false

    var onSelect: ((Transaction) -> Void)? = nil
    var onLoadMore: (() -> Void)? = nil

    @State private var isLastRowVisible = false

    var body: some View {
        LazyVStack(spacing: 0) {
            ForEach(
                Array(transactions.enumerated()),
                id: \.element.id
            ) { index, transaction in

                row(for: transaction)

                if index < transactions.count - 1 {
                    Rectangle()
                        .fill(Theme.Colors.divider)
                        .frame(height: 1)
                        .padding(.horizontal, Theme.Spacing.md)
                } else if onLoadMore != nil {
                    Color.clear
                        .frame(height: 1)
                        .onAppear {
                            isLastRowVisible = true
                            loadMoreIfNeeded()
                        }
                        .onDisappear {
                            isLastRowVisible = false
                        }
                }
            }

            if isLoadingMore {
                ProgressView()
                    .padding(Theme.Spacing.md)
            }
        }
        .background(
            Theme.Colors.surface,
            in: RoundedRectangle(
                cornerRadius: Theme.Radius.hero,
                style: .continuous
            )
        )
        .onChange(of: hasMore) {
            if isLastRowVisible {
                loadMoreIfNeeded()
            }
        }
        .onChange(of: isLoadingMore) {
            if isLastRowVisible {
                loadMoreIfNeeded()
            }
        }
    }

    private func loadMoreIfNeeded() {
        guard hasMore,
              !isLoadingMore else {
            return
        }

        onLoadMore?()
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
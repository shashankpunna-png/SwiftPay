import SwiftUI

enum PaymentResult {
    case credit
    case debit
    case processing
    case cancelled
}

struct TransactionDetailView: View {
    var result: PaymentResult = .debit
    var amount: String = "₹480.00"
    var dateText: String = "26 Oct 2026, 1:15 PM"

    var body: some View {
        VStack(spacing: 0) {
            AppTopBar()

            VStack(spacing: Theme.Spacing.md) {
                PaymentStatusMark(result: result)

                HStack(spacing: Theme.Spacing.xs) {
                    Circle()
                        .fill(result.color)
                        .frame(width: 8, height: 8)
                    Text(result.title)
                        .font(Theme.Typography.labelSmall)
                        .textCase(.uppercase)
                        .tracking(0.6)
                }
                .foregroundStyle(result.color)
                .padding(.horizontal, Theme.Spacing.md)
                .padding(.vertical, Theme.Spacing.xs)
                .background(result.halo, in: Capsule())

                VStack(spacing: Theme.Spacing.xs) {
                    Text(amount)
                        .font(Theme.Typography.displayCurrency)
                        .monospacedDigit()
                        .foregroundStyle(Theme.Colors.neutral)

                    HStack(spacing: Theme.Spacing.xs) {
                        Image(systemName: "clock")
                            .font(.system(size: 14, weight: .medium))
                            .accessibilityHidden(true)
                        Text(dateText)
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
            .padding(Theme.Spacing.md)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Theme.Colors.background)
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

private extension PaymentResult {
    var title: String {
        switch self {
        case .credit, .debit:
            return "Payment successful"
        case .processing:
            return "Processing"
        case .cancelled:
            return "Payment cancelled"
        }
    }

    var symbol: String {
        switch self {
        case .credit, .debit:
            return "checkmark"
        case .processing:
            return "clock"
        case .cancelled:
            return "xmark"
        }
    }

    var color: Color {
        switch self {
        case .credit, .debit:
            return Theme.Colors.success
        case .processing:
            return Theme.Colors.warning
        case .cancelled:
            return Theme.Colors.error
        }
    }

    var halo: Color {
        switch self {
        case .credit, .debit:
            return Theme.Colors.successBackground
        case .processing:
            return Theme.Colors.warningBackground
        case .cancelled:
            return Theme.Colors.errorBackground
        }
    }
}

#Preview("Success") {
    TransactionDetailView(result: .debit, amount: "₹480.00")
}

#Preview("Processing") {
    TransactionDetailView(result: .processing, amount: "₹1,200.00")
}

#Preview("Cancelled") {
    TransactionDetailView(result: .cancelled, amount: "₹899.00")
}

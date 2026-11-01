import SwiftUI

struct ReviewStepView: View {
    var amount: Decimal = 480
    var fee: Decimal = 0
    var recipientName = "Swiggy"
    var recipientPhone = "9988776655"
    var recipientUPI = "swiggy.orders@swiftpay"
    var walletName = "SwiftPay Wallet"
    var walletDetail = "Aarav Shah ••3210"
    var onConfirm: () -> Void = {}

    @Environment(\.dismiss) private var dismiss

    private var total: Decimal { amount + fee }

    var body: some View {
        VStack(spacing: 0) {
            AppTopBar()

            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                    TransferStepIndicator(currentStep: 3)

                    VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                        recipientSection

                        Divider().overlay(Theme.Colors.divider)

                        VStack(spacing: Theme.Spacing.sm) {
                            amountLine("Transfer amount", money(amount))
                            amountLine("Transfer fee", money(fee))
                        }

                        Divider().overlay(Theme.Colors.divider)

                        HStack(alignment: .firstTextBaseline) {
                            Text("Total")
                                .font(Theme.Typography.headlineSmall)
                                .foregroundStyle(Theme.Colors.neutral)
                            Spacer(minLength: Theme.Spacing.sm)
                            Text(money(total))
                                .font(Theme.Typography.headlineMedium)
                                .monospacedDigit()
                                .foregroundStyle(Theme.Colors.primary)
                        }
                    }
                    .padding(Theme.Spacing.md)
                    .background(
                        Theme.Colors.surface,
                        in: RoundedRectangle(cornerRadius: Theme.Radius.hero, style: .continuous)
                    )

                    debitingSection
                }
                .padding(Theme.Spacing.md)
                .padding(.bottom, Theme.Spacing.lg)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Theme.Colors.background)
        .toolbar(.hidden, for: .navigationBar)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            HStack(spacing: Theme.Spacing.gutter) {
                AppButton(title: "Back", systemImage: "chevron.left", style: .secondary) {
                    dismiss()
                }
                AppButton(title: "Confirm pay", systemImage: "lock.fill", action: onConfirm)
            }
            .padding(Theme.Spacing.md)
            .background(Theme.Colors.background)
        }
    }

    private var recipientSection: some View {
        HStack(alignment: .center, spacing: Theme.Spacing.md) {
            Text(initials)
                .font(Theme.Typography.headlineSmall)
                .foregroundStyle(Theme.Colors.primary)
                .frame(width: 48, height: 48)
                .background(Theme.Colors.tertiary)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text("Recipient details")
                    .font(Theme.Typography.bodySmall)
                    .foregroundStyle(Theme.Colors.textSecondary)
                Text(recipientName)
                    .font(Theme.Typography.headlineSmall)
                    .foregroundStyle(Theme.Colors.neutral)
                Text(recipientPhone)
                    .font(Theme.Typography.bodySmall)
                    .monospacedDigit()
                    .foregroundStyle(Theme.Colors.textSecondary)
                Text(recipientUPI)
                    .font(Theme.Typography.bodySmall)
                    .foregroundStyle(Theme.Colors.primary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var debitingSection: some View {
        HStack(alignment: .center, spacing: Theme.Spacing.md) {
            Image(systemName: "wallet.pass")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(Theme.Colors.primary)
                .frame(width: 48, height: 48)
                .background(Theme.Colors.tertiary)
                .clipShape(Circle())
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text("Debiting from")
                    .font(Theme.Typography.bodySmall)
                    .foregroundStyle(Theme.Colors.textSecondary)
                Text(walletName)
                    .font(Theme.Typography.labelLarge)
                    .foregroundStyle(Theme.Colors.neutral)
                Text(walletDetail)
                    .font(Theme.Typography.bodySmall)
                    .foregroundStyle(Theme.Colors.textSecondary)
            }

            Spacer(minLength: 0)
        }
        .padding(Theme.Spacing.md)
        .background(
            Theme.Colors.surface,
            in: RoundedRectangle(cornerRadius: Theme.Radius.hero, style: .continuous)
        )
    }

    private func amountLine(_ title: String, _ value: String) -> some View {
        HStack {
            Text(title)
                .font(Theme.Typography.bodyMedium)
                .foregroundStyle(Theme.Colors.textSecondary)
            Spacer(minLength: Theme.Spacing.sm)
            Text(value)
                .font(Theme.Typography.labelLarge)
                .monospacedDigit()
                .foregroundStyle(Theme.Colors.neutral)
        }
    }

    private var initials: String {
        let letters = recipientName.split(separator: " ").prefix(2).compactMap(\.first)
        let text = String(letters).uppercased()
        return text.isEmpty ? "?" : text
    }

    private func money(_ value: Decimal) -> String {
        Self.currency.string(from: value as NSDecimalNumber) ?? "₹0.00"
    }

    private static let currency: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "INR"
        formatter.locale = Locale(identifier: "en_IN")
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()
}

#Preview {
    ReviewStepView()
}

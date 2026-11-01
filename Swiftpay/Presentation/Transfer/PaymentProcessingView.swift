import SwiftUI

struct PaymentProcessingView: View {
    var recipientName = "Swiggy"
    var recipientPhone = "9988776655"
    var amountText = "₹480.00"
    var accountDetail = "SwiftPay Wallet ••3210"
    var referenceID = "SP429910482190"
    var onFinished: () -> Void = {}

    var body: some View {
        processing
            .toolbar(.hidden, for: .navigationBar)
            .task {
                try? await Task.sleep(for: .seconds(3))
                guard !Task.isCancelled else { return }
                onFinished()
            }
    }

    private var processing: some View {
        VStack(spacing: Theme.Spacing.xl) {
            spinner

            VStack(spacing: Theme.Spacing.xs) {
                Text("Processing payment")
                    .font(Theme.Typography.headlineMedium)
                    .foregroundStyle(Theme.Colors.neutral)
                Text("Please do not press Back or close the app")
                    .font(Theme.Typography.bodySmall)
                    .foregroundStyle(Theme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: Theme.Spacing.md) {
                Text("Paying to")
                    .font(Theme.Typography.labelSmall)
                    .textCase(.uppercase)
                    .tracking(0.6)
                    .foregroundStyle(Theme.Colors.textSecondary)

                HStack(spacing: Theme.Spacing.sm) {
                    Text(initials)
                        .font(Theme.Typography.labelLarge)
                        .foregroundStyle(Theme.Colors.primary)
                        .frame(width: 40, height: 40)
                        .background(Theme.Colors.tertiary)
                        .clipShape(Circle())

                    VStack(alignment: .leading, spacing: 2) {
                        Text(recipientName)
                            .font(Theme.Typography.labelLarge)
                            .foregroundStyle(Theme.Colors.neutral)
                        Text(recipientPhone)
                            .font(Theme.Typography.bodySmall)
                            .monospacedDigit()
                            .foregroundStyle(Theme.Colors.textSecondary)
                    }
                }

                Divider().overlay(Theme.Colors.divider)

                Text(amountText)
                    .font(Theme.Typography.displayCurrency)
                    .monospacedDigit()
                    .foregroundStyle(Theme.Colors.neutral)

                Text(accountDetail)
                    .font(Theme.Typography.bodySmall)
                    .foregroundStyle(Theme.Colors.textSecondary)
            }
            .padding(Theme.Spacing.lg)
            .frame(maxWidth: .infinity)
            .background(
                Theme.Colors.surface,
                in: RoundedRectangle(cornerRadius: Theme.Radius.hero, style: .continuous)
            )

            VStack(spacing: Theme.Spacing.sm) {
                HStack(spacing: Theme.Spacing.xs) {
                    Image(systemName: "checkmark.shield.fill")
                        .font(.system(size: 16, weight: .semibold))
                        .accessibilityHidden(true)
                    Text("100% Secure")
                        .font(Theme.Typography.labelLarge)
                }
                .foregroundStyle(Theme.Colors.primary)

                Text("Ref ID: \(referenceID)")
                    .font(Theme.Typography.bodySmall)
                    .monospacedDigit()
                    .foregroundStyle(Theme.Colors.textSecondary)
            }
        }
        .padding(Theme.Spacing.md)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Theme.Colors.background)
    }

    private var spinner: some View {
        TimelineView(.animation) { timeline in
            let period = 0.9
            let elapsed = timeline.date.timeIntervalSinceReferenceDate
            let angle = (elapsed.truncatingRemainder(dividingBy: period) / period) * 360

            ZStack {
                Circle()
                    .stroke(Theme.Colors.tertiary, lineWidth: 4)
                Circle()
                    .trim(from: 0, to: 0.28)
                    .stroke(
                        Theme.Colors.primary,
                        style: StrokeStyle(lineWidth: 4, lineCap: .round)
                    )
                    .rotationEffect(.degrees(angle))

                Image(systemName: "lock.fill")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(Theme.Colors.primary)
                    .frame(width: 48, height: 48)
                    .background(Theme.Colors.tertiary)
                    .clipShape(Circle())
            }
        }
        .frame(width: 80, height: 80)
        .accessibilityLabel("Processing payment")
    }

    private var initials: String {
        let letters = recipientName.split(separator: " ").prefix(2).compactMap(\.first)
        let text = String(letters).uppercased()
        return text.isEmpty ? "?" : text
    }
}

#Preview {
    PaymentProcessingView()
}

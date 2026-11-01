import SwiftUI

struct AmountStepView: View {
    var name: String
    var upiID: String

    @State private var amountText = "0"
    @FocusState private var isAmountFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            AppTopBar()

            VStack(spacing: Theme.Spacing.xl) {
                TransferStepIndicator(currentStep: 2)

                VStack(spacing: Theme.Spacing.sm) {
                    Text(initials)
                        .font(Theme.Typography.headlineSmall)
                        .foregroundStyle(Theme.Colors.primary)
                        .frame(width: 72, height: 72)
                        .background(Theme.Colors.tertiary)
                        .clipShape(Circle())

                    Text("Paying \(name)")
                        .font(Theme.Typography.headlineSmall)
                        .foregroundStyle(Theme.Colors.neutral)

                    Text(upiID)
                        .font(Theme.Typography.bodyMedium)
                        .foregroundStyle(Theme.Colors.textSecondary)
                }
                .padding(.top, Theme.Spacing.xl)

                HStack(alignment: .firstTextBaseline, spacing: Theme.Spacing.xs) {
                    Text("₹")
                    TextField("0", text: $amountText)
                        .keyboardType(.decimalPad)
                        .focused($isAmountFocused)
                        .fixedSize(horizontal: true, vertical: false)
                        .onChange(of: amountText) { _, newValue in
                            let cleaned = Self.normalized(newValue)
                            if cleaned != newValue {
                                amountText = cleaned
                            }
                        }
                }
                .font(.system(size: 48, weight: .bold))
                .monospacedDigit()
                .foregroundStyle(Theme.Colors.neutral)
            }
            .padding(Theme.Spacing.md)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .background(Theme.Colors.background)
        .safeAreaInset(edge: .bottom, spacing: 0) {
            HStack(spacing: Theme.Spacing.gutter) {
                AppButton(title: "Back", systemImage: "chevron.left", style: .secondary) {}
                AppButton(title: "Proceed") {}
            }
            .padding(Theme.Spacing.md)
            .background(Theme.Colors.background)
        }
        .onAppear {
            isAmountFocused = true
        }
    }

    private var initials: String {
        let letters = name.split(separator: " ").prefix(2).compactMap(\.first)
        let text = String(letters).uppercased()
        return text.isEmpty ? "?" : text
    }

    private static func normalized(_ raw: String) -> String {
        var result = ""
        var dotSeen = false
        var fractionCount = 0

        for character in raw {
            if character.isNumber {
                if dotSeen {
                    guard fractionCount < 2 else { continue }
                    fractionCount += 1
                }
                result.append(character)
            } else if character == ".", !dotSeen {
                dotSeen = true
                result.append(character)
            }
        }

        while result.hasPrefix("0"), !result.hasPrefix("0."), result.count > 1 {
            result.removeFirst()
        }

        return result.isEmpty ? "0" : result
    }
}

#Preview {
    AmountStepView(name: "Swiggy", upiID: "swiggy.orders@swiftpay")
}

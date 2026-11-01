import SwiftUI

struct TransferStepIndicator: View {
    let currentStep: Int

    private let titles = ["Recipient", "Amount", "Review"]
    private let circleSize: CGFloat = 28

    var body: some View {
        VStack(spacing: Theme.Spacing.xs) {
            ZStack {
                Rectangle()
                    .fill(Theme.Colors.border)
                    .frame(height: 2)
                    .padding(.horizontal, circleSize / 2)

                HStack(spacing: 0) {
                    ForEach(titles.indices, id: \.self) { index in
                        if index > 0 {
                            Spacer(minLength: 0)
                        }
                        circle(number: index + 1)
                    }
                }
            }

            HStack(spacing: 0) {
                ForEach(titles.indices, id: \.self) { index in
                    Text(titles[index])
                        .font(Theme.Typography.labelSmall)
                        .foregroundStyle(index + 1 == currentStep ? Theme.Colors.primary : Theme.Colors.textSecondary)
                        .frame(maxWidth: .infinity, alignment: labelAlignment(for: index))
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Step \(currentStep) of \(titles.count), \(titles[currentStep - 1])")
    }

    private func circle(number: Int) -> some View {
        let isCurrent = number == currentStep

        return Text("\(number)")
            .font(Theme.Typography.labelLarge)
            .foregroundStyle(isCurrent ? Theme.Colors.onPrimary : Theme.Colors.textSecondary)
            .frame(width: circleSize, height: circleSize)
            .background(isCurrent ? Theme.Colors.primary : Theme.Colors.surface)
            .clipShape(Circle())
            .overlay {
                Circle()
                    .stroke(isCurrent ? Theme.Colors.primary : Theme.Colors.border, lineWidth: 1)
            }
    }

    private func labelAlignment(for index: Int) -> Alignment {
        switch index {
        case 0:
            return .leading
        case titles.count - 1:
            return .trailing
        default:
            return .center
        }
    }
}

#Preview {
    TransferStepIndicator(currentStep: 1)
        .padding()
}

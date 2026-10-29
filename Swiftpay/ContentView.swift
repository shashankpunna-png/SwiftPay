import SwiftUI

struct ContentView: View {
    private let swatches: [(name: String, color: Color)] = [
        ("Primary", Theme.Colors.primary),
        ("Secondary", Theme.Colors.secondary),
        ("Tertiary", Theme.Colors.tertiary),
        ("Neutral", Theme.Colors.neutral),
        ("Success", Theme.Colors.success),
        ("Error", Theme.Colors.error)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("SwiftPay")
                .font(Theme.Typography.headlineLarge)
                .foregroundStyle(Theme.Colors.neutral)

            Text("Theme from Stitch")
                .font(Theme.Typography.bodyMedium)
                .foregroundStyle(Theme.Colors.textSecondary)

            ForEach(swatches, id: \.name) { swatch in
                HStack(spacing: Theme.Spacing.md) {
                    RoundedRectangle(cornerRadius: Theme.Radius.input)
                        .fill(swatch.color)
                        .frame(width: 44, height: 44)
                        .overlay {
                            RoundedRectangle(cornerRadius: Theme.Radius.input)
                                .stroke(Theme.Colors.border, lineWidth: 1)
                        }
                    Text(swatch.name)
                        .font(Theme.Typography.labelLarge)
                        .foregroundStyle(Theme.Colors.neutral)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.background)
    }
}

#Preview {
    ContentView()
}

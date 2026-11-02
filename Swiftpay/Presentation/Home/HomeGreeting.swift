import SwiftUI

struct HomeGreeting: View {
    let name: String
    let upiID: String

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            Text(name.isEmpty ? greeting : "\(greeting), \(name)")
                .font(Theme.Typography.headlineMedium)
                .foregroundStyle(Theme.Colors.neutral)
                .lineLimit(1)
                .minimumScaleFactor(0.75)

            HStack(spacing: Theme.Spacing.xs) {
                Text("UPI ID:")
                    .foregroundStyle(Theme.Colors.textSecondary)
                Text(upiID)
                    .foregroundStyle(Theme.Colors.primary)
            }
            .font(Theme.Typography.bodyMedium)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, Theme.Spacing.md)
        .padding(.top, Theme.Spacing.md)
        .padding(.bottom, Theme.Spacing.sm)
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:
            return "Good morning"
        case 12..<17:
            return "Good afternoon"
        case 17..<22:
            return "Good evening"
        default:
            return "Hello"
        }
    }
}

#Preview {
    HomeGreeting(name: "Aarav", upiID: "aarav.shah@swiftpay")
        .background(Theme.Colors.background)
}

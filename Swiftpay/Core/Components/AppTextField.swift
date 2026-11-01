import SwiftUI
import UIKit

struct AppTextField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var keyboard: UIKeyboardType = .default
    var capitalization: TextInputAutocapitalization = .words

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            Text(title)
                .font(Theme.Typography.labelLarge)
                .foregroundStyle(Theme.Colors.neutral)

            TextField(placeholder, text: $text)
                .font(Theme.Typography.bodyLarge)
                .foregroundStyle(Theme.Colors.neutral)
                .keyboardType(keyboard)
                .textInputAutocapitalization(capitalization)
                .autocorrectionDisabled()
                .padding(.horizontal, Theme.Spacing.md)
                .frame(height: 48)
                .background(
                    Theme.Colors.fieldBackground,
                    in: RoundedRectangle(cornerRadius: Theme.Radius.input, style: .continuous)
                )
        }
    }
}

#Preview {
    AppTextField(title: "Name", placeholder: "Recipient name", text: .constant(""))
        .padding()
}

import SwiftUI

struct TransactionSearchField: View {
    @Binding var text: String

    var body: some View {
        HStack(spacing: Theme.Spacing.sm) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 18, weight: .medium))
                .foregroundStyle(Theme.Colors.textSecondary)

            TextField("Search transactions", text: $text)
                .font(Theme.Typography.bodyMedium)
                .foregroundStyle(Theme.Colors.neutral)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundStyle(Theme.Colors.inactive)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Clear search")
            }
        }
        .padding(.horizontal, Theme.Spacing.md)
        .frame(height: 44)
        .background(
            Theme.Colors.fieldBackground,
            in: RoundedRectangle(cornerRadius: Theme.Radius.input, style: .continuous)
        )
    }
}

private struct TransactionSearchFieldPreview: View {
    @State private var text = ""

    var body: some View {
        TransactionSearchField(text: $text)
            .padding(Theme.Spacing.md)
            .background(Theme.Colors.background)
    }
}

#Preview {
    TransactionSearchFieldPreview()
}

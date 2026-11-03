import SwiftUI

enum TransactionListFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case credit = "Credit"
    case debit = "Debit"

    var id: String { rawValue }
}

struct TransactionFilterBar: View {
    @Binding var selection: TransactionListFilter
    var isDateFilterActive: Bool
    let onDateTap: () -> Void

    var body: some View {
        HStack(spacing: Theme.Spacing.sm) {
            ForEach(TransactionListFilter.allCases) { filter in
                Button {
                    selection = filter
                } label: {
                    Text(filter.rawValue)
                        .font(Theme.Typography.labelLarge)
                        .foregroundStyle(selection == filter ? Theme.Colors.onPrimary : Theme.Colors.textSecondary)
                        .padding(.horizontal, Theme.Spacing.md)
                        .padding(.vertical, Theme.Spacing.sm)
                        .background(
                            selection == filter ? Theme.Colors.primary : Theme.Colors.fieldBackground,
                            in: Capsule()
                        )
                }
                .buttonStyle(.plain)
            }

            Spacer(minLength: Theme.Spacing.sm)

            Button(action: onDateTap) {
                Image(systemName: "calendar")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(isDateFilterActive ? Theme.Colors.onPrimary : Theme.Colors.textSecondary)
                    .frame(width: 36, height: 36)
                    .background(
                        isDateFilterActive ? Theme.Colors.primary : Theme.Colors.fieldBackground,
                        in: Circle()
                    )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Date range")
        }
    }
}

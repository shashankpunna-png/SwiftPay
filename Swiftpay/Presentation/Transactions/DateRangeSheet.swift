import SwiftUI

struct DateRangeSheet: View {
    @Environment(\.dismiss) private var dismiss

    @State private var start: Date
    @State private var end: Date

    let onApply: (ClosedRange<Date>) -> Void
    let onClear: () -> Void

    init(
        range: ClosedRange<Date>?,
        onApply: @escaping (ClosedRange<Date>) -> Void,
        onClear: @escaping () -> Void
    ) {
        let calendar = Calendar.current
        let defaultEnd = Date()
        let defaultStart = calendar.date(byAdding: .day, value: -30, to: defaultEnd) ?? defaultEnd
        _start = State(initialValue: range?.lowerBound ?? defaultStart)
        _end = State(initialValue: range?.upperBound ?? defaultEnd)
        self.onApply = onApply
        self.onClear = onClear
    }

    var body: some View {
        NavigationStack {
            Form {
                DatePicker("From", selection: $start, displayedComponents: .date)
                DatePicker("To", selection: $end, in: start..., displayedComponents: .date)
            }
            .navigationTitle("Select Date range")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Clear") {
                        onClear()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") {
                        onApply(DayRange.fullDays(from: start, to: end))
                        dismiss()
                    }
                }
            }
        }
        .tint(Theme.Colors.primary)
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}

import Foundation

enum DayRange {
    static func fullDays(from start: Date, to end: Date) -> ClosedRange<Date> {
        let calendar = Calendar.current
        let first = calendar.startOfDay(for: min(start, end))
        let lastDay = calendar.startOfDay(for: max(start, end))
        let last = calendar.date(byAdding: DateComponents(day: 1, second: -1), to: lastDay) ?? lastDay
        return first...last
    }
}

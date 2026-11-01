import Foundation

enum SampleTransactions {
    static let all: [TransactionItem] = [
        TransactionItem(id: UUID(), title: "Swiggy", date: date(daysAgo: 0, hour: 13, minute: 15), amount: 480, kind: .debit),
        TransactionItem(id: UUID(), title: "Rahul Mehta", date: date(daysAgo: 0, hour: 9, minute: 40), amount: 2500, kind: .credit),
        TransactionItem(id: UUID(), title: "Neha Iyer", date: date(daysAgo: 1, hour: 19, minute: 5), amount: 1200, kind: .debit),
        TransactionItem(id: UUID(), title: "Amazon", date: date(daysAgo: 2, hour: 16, minute: 20), amount: 899, kind: .debit),
        TransactionItem(id: UUID(), title: "Rohan Verma", date: date(daysAgo: 3, hour: 20, minute: 30), amount: 1250, kind: .credit),
        TransactionItem(id: UUID(), title: "Tata Power", date: date(daysAgo: 5, hour: 15, minute: 45), amount: 2140, kind: .debit),
        TransactionItem(id: UUID(), title: "Starbucks", date: date(daysAgo: 8, hour: 9, minute: 20), amount: 350, kind: .debit)
    ]

    static var newestFirst: [TransactionItem] {
        all.sorted { $0.date > $1.date }
    }

    private static func date(daysAgo: Int, hour: Int, minute: Int) -> Date {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: Date())
        let day = calendar.date(byAdding: .day, value: -daysAgo, to: start) ?? start
        return calendar.date(bySettingHour: hour, minute: minute, second: 0, of: day) ?? day
    }
}

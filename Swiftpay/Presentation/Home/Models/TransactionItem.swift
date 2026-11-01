import Foundation

struct TransactionItem: Identifiable, Hashable {
    enum Kind: String {
        case credit = "Credit"
        case debit = "Debit"
    }

    let id: UUID
    let title: String
    let date: Date
    let amount: Decimal
    let kind: Kind

    var initials: String {
        let words = title.split(separator: " ")
        let letters = words.prefix(2).compactMap(\.first)
        return String(letters).uppercased()
    }

    var dateText: String {
        date.formatted(.dateTime.day().month(.abbreviated).hour().minute())
    }

    var signedAmount: String {
        let formatted = Self.currency.string(from: NSDecimalNumber(decimal: amount)) ?? "₹0.00"
        switch kind {
        case .credit:
            return "+ \(formatted)"
        case .debit:
            return "− \(formatted)"
        }
    }

    private static let currency: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "INR"
        formatter.locale = Locale(identifier: "en_IN")
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()
}

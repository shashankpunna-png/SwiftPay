import Foundation

struct User: Equatable, Sendable {
    var id: String
    var name: String
    var mobileNumber: String
    var upiId: String
    var walletBalance: Decimal
    var currency: String
    var photoUrl: String?
    var photoData: Data?

    var givenName: String {
        name.split(separator: " ").first.map(String.init) ?? name
    }

    var initials: String {
        let letters = name.split(separator: " ").prefix(2).compactMap(\.first)
        let text = String(letters).uppercased()
        return text.isEmpty ? "?" : text
    }

    var balanceText: String {
        Self.plainAmount.string(from: walletBalance as NSDecimalNumber) ?? "0.00"
    }

    var formattedBalance: String {
        Self.currencyAmount.string(from: walletBalance as NSDecimalNumber) ?? "₹0.00"
    }

    var accountDetail: String {
        let digits = mobileNumber.filter(\.isNumber)
        let suffix = digits.suffix(4)
        guard !name.isEmpty else { return String(suffix) }
        guard !suffix.isEmpty else { return name }
        return "\(name) ••\(suffix)"
    }

    private static let plainAmount: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = false
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()

    private static let currencyAmount: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "INR"
        formatter.locale = Locale(identifier: "en_IN")
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        return formatter
    }()
}

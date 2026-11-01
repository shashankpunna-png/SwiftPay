import Foundation
import UIKit

@MainActor
@Observable
final class UserProfileStore {
    static let shared = UserProfileStore()

    var name: String {
        didSet { save() }
    }

    var phone: String {
        didSet { save() }
    }

    var upiID: String {
        didSet { save() }
    }

    var balanceText: String {
        didSet { save() }
    }

    var showsBalanceOnLaunch: Bool {
        didSet { save() }
    }

    var image: UIImage? {
        didSet { saveImage() }
    }

    private var isLoading = false
    private let defaults = UserDefaults.standard

    private init() {
        isLoading = true
        name = defaults.string(forKey: Key.name) ?? "Aarav Shah"
        phone = defaults.string(forKey: Key.phone) ?? "9876543210"
        upiID = defaults.string(forKey: Key.upiID) ?? "aarav.shah@swiftpay"
        balanceText = defaults.string(forKey: Key.balance) ?? "10000.00"
        showsBalanceOnLaunch = defaults.object(forKey: Key.showsBalance) as? Bool ?? true
        if let data = try? Data(contentsOf: Self.imageURL), let saved = UIImage(data: data) {
            image = saved
        } else {
            image = nil
        }
        isLoading = false
    }

    var givenName: String {
        name.split(separator: " ").first.map(String.init) ?? name
    }

    var initials: String {
        let letters = name.split(separator: " ").prefix(2).compactMap(\.first)
        let text = String(letters).uppercased()
        return text.isEmpty ? "?" : text
    }

    var balance: Decimal {
        Decimal(string: balanceText, locale: Locale(identifier: "en_US_POSIX")) ?? 0
    }

    var formattedBalance: String {
        Self.currency.string(from: balance as NSDecimalNumber) ?? "₹0.00"
    }

    var accountDetail: String {
        let digits = phone.filter(\.isNumber)
        let suffix = digits.suffix(4)
        guard !name.isEmpty else { return String(suffix) }
        guard !suffix.isEmpty else { return name }
        return "\(name) ••\(suffix)"
    }

    private func save() {
        guard !isLoading else { return }
        defaults.set(name, forKey: Key.name)
        defaults.set(phone, forKey: Key.phone)
        defaults.set(upiID, forKey: Key.upiID)
        defaults.set(balanceText, forKey: Key.balance)
        defaults.set(showsBalanceOnLaunch, forKey: Key.showsBalance)
    }

    private func saveImage() {
        guard !isLoading else { return }
        let url = Self.imageURL
        if let image, let data = image.jpegData(compressionQuality: 0.8) {
            try? FileManager.default.createDirectory(
                at: url.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            try? data.write(to: url, options: .atomic)
        } else {
            try? FileManager.default.removeItem(at: url)
        }
    }

    private static var imageURL: URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        return base.appendingPathComponent("SwiftPay/profile.jpg")
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

    private enum Key {
        static let name = "profile.name"
        static let phone = "profile.phone"
        static let upiID = "profile.upiID"
        static let balance = "profile.balance"
        static let showsBalance = "profile.showsBalanceOnLaunch"
    }
}

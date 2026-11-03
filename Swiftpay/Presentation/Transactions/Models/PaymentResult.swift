import SwiftUI

enum PaymentResult {
    case success
    case pending
    case cancelled

    var title: String {
        switch self {
        case .success:
            return "Payment successful"
        case .pending:
            return "Processing"
        case .cancelled:
            return "Payment cancelled"
        }
    }

    var symbol: String {
        switch self {
        case .success: return "checkmark"
        case .pending: return "clock"
        case .cancelled: return "xmark"
        }
    }

    var color: Color {
        switch self {
        case .success: return Theme.Colors.success
        case .pending: return Theme.Colors.warning
        case .cancelled: return Theme.Colors.error
        }
    }

    var halo: Color {
        switch self {
        case .success: return Theme.Colors.successBackground
        case .pending: return Theme.Colors.warningBackground
        case .cancelled: return Theme.Colors.errorBackground
        }
    }

    var accountBadge: String {
        switch self {
        case .success: return "Active"
        case .pending: return "Processing"
        case .cancelled: return "Cancelled"
        }
    }
}
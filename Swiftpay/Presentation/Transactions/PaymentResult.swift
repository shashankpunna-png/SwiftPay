import SwiftUI

enum PaymentResult {
    case credit
    case debit
    case processing
    case cancelled

    var title: String {
        switch self {
        case .credit, .debit:
            return "Payment successful"
        case .processing:
            return "Processing"
        case .cancelled:
            return "Payment cancelled"
        }
    }

    var symbol: String {
        switch self {
        case .credit, .debit:
            return "checkmark"
        case .processing:
            return "clock"
        case .cancelled:
            return "xmark"
        }
    }

    var color: Color {
        switch self {
        case .credit, .debit:
            return Theme.Colors.success
        case .processing:
            return Theme.Colors.warning
        case .cancelled:
            return Theme.Colors.error
        }
    }

    var halo: Color {
        switch self {
        case .credit, .debit:
            return Theme.Colors.successBackground
        case .processing:
            return Theme.Colors.warningBackground
        case .cancelled:
            return Theme.Colors.errorBackground
        }
    }

    var counterpartyTitle: String {
        switch self {
        case .credit:
            return "Received from"
        case .debit, .processing, .cancelled:
            return "Paid to"
        }
    }

    var counterpartySymbol: String {
        switch self {
        case .credit:
            return "arrow.down.left"
        case .debit, .processing, .cancelled:
            return "arrow.up.right"
        }
    }

    var accountTitle: String {
        switch self {
        case .credit:
            return "Credited to"
        case .debit, .processing, .cancelled:
            return "Debited from"
        }
    }

    var accountBadge: String {
        switch self {
        case .credit, .debit:
            return "Active"
        case .processing:
            return "Processing"
        case .cancelled:
            return "Cancelled"
        }
    }
}

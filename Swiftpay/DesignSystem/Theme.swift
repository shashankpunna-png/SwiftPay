import SwiftUI

enum Theme {
    enum Colors {
        static let primary = Color(hex: 0x5F259F)
        static let onPrimary = Color(hex: 0xFFFFFF)
        static let secondary = Color(hex: 0x35115E)
        static let tertiary = Color(hex: 0xF2EAFB)
        static let neutral = Color(hex: 0x111827)

        static let background = Color(hex: 0xF8F9FA)
        static let surface = Color(hex: 0xFFFFFF)
        static let textSecondary = Color(hex: 0x6B7280)
        static let border = Color(hex: 0xE5E7EB)
        static let divider = Color(hex: 0xF3F4F6)
        static let fieldBackground = Color(hex: 0xF3F4F6)
        static let inactive = Color(hex: 0x9CA3AF)

        static let success = Color(hex: 0x16A34A)
        static let successBackground = Color(hex: 0xDCFCE7)
        static let error = Color(hex: 0xDC2626)
        static let errorBackground = Color(hex: 0xFEE2E2)
    }

    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let gutter: CGFloat = 12
    }

    enum Radius {
        static let input: CGFloat = 12
        static let button: CGFloat = 14
        static let card: CGFloat = 16
        static let hero: CGFloat = 24
        static let pill: CGFloat = 999
    }

    enum Typography {
        static let displayCurrency = Font.system(size: 32, weight: .bold)
        static let headlineLarge = Font.system(size: 28, weight: .bold)
        static let headlineMedium = Font.system(size: 22, weight: .semibold)
        static let headlineSmall = Font.system(size: 18, weight: .semibold)
        static let bodyLarge = Font.system(size: 16, weight: .regular)
        static let bodyMedium = Font.system(size: 14, weight: .regular)
        static let bodySmall = Font.system(size: 12, weight: .regular)
        static let labelLarge = Font.system(size: 14, weight: .semibold)
        static let labelSmall = Font.system(size: 11, weight: .medium)
    }
}

extension Color {
    init(hex: UInt32, opacity: Double = 1) {
        let red = Double((hex >> 16) & 0xFF) / 255
        let green = Double((hex >> 8) & 0xFF) / 255
        let blue = Double(hex & 0xFF) / 255
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }
}

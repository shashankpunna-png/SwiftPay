import SwiftUI

struct AppButton: View {
    enum Style {
        case primary
        case secondary

        var background: Color {
            switch self {
            case .primary:
                return Theme.Colors.primary
            case .secondary:
                return Theme.Colors.tertiary
            }
        }

        var foreground: Color {
            switch self {
            case .primary:
                return Theme.Colors.onPrimary
            case .secondary:
                return Theme.Colors.primary
            }
        }
    }

    let title: String
    var systemImage: String? = nil
    var style: Style = .primary
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Theme.Spacing.sm) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 18, weight: .semibold))
                        .accessibilityHidden(true)
                }
                Text(title)
                    .font(Theme.Typography.labelLarge)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
        .buttonStyle(AppButtonStyle(style: style))
    }
}

struct AppButtonStyle: ButtonStyle {
    var style: AppButton.Style
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(style.foreground)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                style.background,
                in: RoundedRectangle(cornerRadius: Theme.Radius.button, style: .continuous)
            )
            .opacity(isEnabled ? (configuration.isPressed ? 0.85 : 1) : 0.5)
            .scaleEffect(configuration.isPressed && isEnabled ? 0.98 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

#Preview {
    HStack(spacing: Theme.Spacing.gutter) {
        AppButton(title: "Send Money", systemImage: "paperplane.fill") {}
        AppButton(title: "Transactions", systemImage: "clock.arrow.circlepath", style: .secondary) {}
    }
    .padding(Theme.Spacing.md)
    .background(Theme.Colors.background)
}

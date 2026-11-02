import SwiftUI

struct AppTopBar: View {
    var onNotificationsTap: () -> Void = {}

    @Environment(\.openProfile) private var openProfile
    @Environment(\.userDetails) private var userDetails

    var body: some View {
        ZStack {
            Text("SwiftPay")
                .font(Theme.Typography.headlineSmall)
                .foregroundStyle(Theme.Colors.primary)

            HStack {
                profileButton
                Spacer()
                notificationsButton
            }
        }
        .padding(.horizontal, Theme.Spacing.md)
        .frame(height: 56)
        .background(Theme.Colors.surface)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Theme.Colors.divider)
                .frame(height: 1)
        }
        .background(Theme.Colors.surface.ignoresSafeArea(edges: .top))
    }

    private var profileButton: some View {
        Button(action: openProfile) {
            profileAvatar
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Profile")
    }

    @ViewBuilder
    private var profileAvatar: some View {
        if let image = userDetails?.photo {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 40, height: 40)
                .clipShape(Circle())
        } else {
            Text(userDetails?.user?.initials ?? "?")
                .font(Theme.Typography.labelLarge)
                .foregroundStyle(Theme.Colors.primary)
                .frame(width: 40, height: 40)
                .background(Theme.Colors.tertiary)
                .clipShape(Circle())
        }
    }

    private var notificationsButton: some View {
        Button(action: onNotificationsTap) {
            Image(systemName: "bell")
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(Theme.Colors.neutral)
                .frame(width: 40, height: 40)
                .overlay(alignment: .topTrailing) {
                    Circle()
                        .fill(Theme.Colors.error)
                        .frame(width: 8, height: 8)
                        .offset(x: -8, y: 8)
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Notifications")
    }
}

#Preview {
    AppTopBar()
        .environment(\.userDetails, UserDetailsViewModel.preview)
}

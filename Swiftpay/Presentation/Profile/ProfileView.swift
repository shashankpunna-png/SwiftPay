import PhotosUI
import SwiftUI

struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var photoItem: PhotosPickerItem?

    private var profile: UserProfileStore { .shared }

    var body: some View {
        @Bindable var profile = UserProfileStore.shared

        VStack(spacing: 0) {
            header

            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                    photoPicker

                    AppTextField(title: "Name", placeholder: "Your name", text: $profile.name)
                    AppTextField(
                        title: "Mobile number",
                        placeholder: "10-digit mobile number",
                        text: $profile.phone,
                        keyboard: .phonePad,
                        capitalization: .never
                    )
                    AppTextField(
                        title: "UPI ID",
                        placeholder: "name@swiftpay",
                        text: $profile.upiID,
                        keyboard: .emailAddress,
                        capitalization: .never
                    )
                    AppTextField(
                        title: "Wallet balance",
                        placeholder: "0.00",
                        text: $profile.balanceText,
                        keyboard: .decimalPad,
                        capitalization: .never
                    )

                    Toggle(isOn: $profile.showsBalanceOnLaunch) {
                        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                            Text("Show balance on launch")
                                .font(Theme.Typography.labelLarge)
                                .foregroundStyle(Theme.Colors.neutral)
                            Text("The eye on Home uses this same choice.")
                                .font(Theme.Typography.bodySmall)
                                .foregroundStyle(Theme.Colors.textSecondary)
                        }
                    }
                    .tint(Theme.Colors.primary)
                    .padding(Theme.Spacing.md)
                    .background(
                        Theme.Colors.surface,
                        in: RoundedRectangle(cornerRadius: Theme.Radius.hero, style: .continuous)
                    )

                    VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                        Text("Used when you send")
                            .font(Theme.Typography.headlineSmall)
                            .foregroundStyle(Theme.Colors.neutral)
                        detailLine("Wallet", "SwiftPay Wallet")
                        detailLine("Receipt name", profile.accountDetail)
                        detailLine("Your UPI ID", profile.upiID)
                    }
                    .padding(Theme.Spacing.md)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        Theme.Colors.surface,
                        in: RoundedRectangle(cornerRadius: Theme.Radius.hero, style: .continuous)
                    )
                }
                .padding(Theme.Spacing.md)
                .padding(.bottom, Theme.Spacing.lg)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(Theme.Colors.background)
    }

    private var header: some View {
        ZStack {
            Text("Profile")
                .font(Theme.Typography.headlineSmall)
                .foregroundStyle(Theme.Colors.neutral)

            HStack {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(Theme.Colors.primary)
                        .frame(width: 40, height: 40)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Back")

                Spacer()
            }
        }
        .padding(.horizontal, Theme.Spacing.md)
        .frame(height: 56)
        .background(Theme.Colors.surface)
    }

    private var photoPicker: some View {
        VStack(spacing: Theme.Spacing.sm) {
            PhotosPicker(selection: $photoItem, matching: .images) {
                ZStack(alignment: .bottomTrailing) {
                    avatar
                    Image(systemName: "camera.fill")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(Theme.Colors.onPrimary)
                        .frame(width: 28, height: 28)
                        .background(Theme.Colors.primary)
                        .clipShape(Circle())
                }
            }
            .buttonStyle(.plain)
            .onChange(of: photoItem) { _, item in
                guard let item else { return }
                Task {
                    guard let data = try? await item.loadTransferable(type: Data.self),
                          let image = UIImage(data: data) else { return }
                    profile.image = image
                }
            }

            Text(profile.image == nil ? "Upload photo" : "Change photo")
                .font(Theme.Typography.bodySmall)
                .foregroundStyle(Theme.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private var avatar: some View {
        if let image = profile.image {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 96, height: 96)
                .clipShape(Circle())
        } else {
            Text(profile.initials)
                .font(Theme.Typography.headlineMedium)
                .foregroundStyle(Theme.Colors.primary)
                .frame(width: 96, height: 96)
                .background(Theme.Colors.tertiary)
                .clipShape(Circle())
        }
    }

    private func detailLine(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(Theme.Typography.bodySmall)
                .foregroundStyle(Theme.Colors.textSecondary)
            Text(value.isEmpty ? "—" : value)
                .font(Theme.Typography.labelLarge)
                .foregroundStyle(Theme.Colors.neutral)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    ProfileView()
}

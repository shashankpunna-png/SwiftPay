import PhotosUI
import SwiftUI
import UIKit

struct ProfileView: View {
    @Environment(\.userDetails) private var userDetails

    var body: some View {
        if let userDetails {
            ProfileForm(model: userDetails)
        }
    }
}

private struct ProfileForm: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var model: UserDetailsViewModel

    @State private var photoItem: PhotosPickerItem?
    @State private var name = ""
    @State private var phone = ""
    @State private var upiID = ""
    @State private var image: UIImage?
    @State private var photoFile: String?
    @State private var appliedUserID: String?

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView {
                VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                    if model.isRefreshing && model.user == nil {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    }

                    if let loadError = model.loadError, model.user == nil {
                        Text(loadError)
                            .font(Theme.Typography.bodySmall)
                            .foregroundStyle(Theme.Colors.error)
                        AppButton(title: "Try again", style: .secondary) {
                            Task { await model.load() }
                        }
                    }

                    if model.isShowingCachedProfile {
                        Text("Showing the profile saved on this iPhone.")
                            .font(Theme.Typography.bodySmall)
                            .foregroundStyle(Theme.Colors.textSecondary)
                    }

                    photoPicker

                    AppTextField(title: "Name", placeholder: "Your name", text: $name)
                    AppTextField(
                        title: "Mobile number",
                        placeholder: "10-digit mobile number",
                        text: $phone,
                        keyboard: .phonePad,
                        capitalization: .never
                    )
                    AppTextField(
                        title: "UPI ID",
                        placeholder: "name@swiftpay",
                        text: $upiID,
                        keyboard: .emailAddress,
                        capitalization: .never
                    )

                    if let saveError = model.saveError {
                        Text(saveError)
                            .font(Theme.Typography.bodySmall)
                            .foregroundStyle(Theme.Colors.error)
                    }

                    AppButton(title: model.isSaving ? "Saving…" : "Save") {
                        Task { await save() }
                    }
                    .disabled(model.isSaving)

                    Toggle(isOn: $model.showsBalanceOnLaunch) {
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
                        detailLine("Receipt name", draftUser.accountDetail)
                        detailLine("Your UPI ID", upiID)
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
        .task {
            await model.load()
        }
        .onChange(of: model.user, initial: true) { _, user in
            guard let user else { return }
            if appliedUserID == nil || !isDirty {
                apply(user)
            }
        }
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
                          let picked = UIImage(data: data),
                          let jpeg = picked.jpegData(compressionQuality: 0.8) else { return }
                    image = picked
                    photoFile = jpeg.base64EncodedString()
                }
            }

            Text(image == nil ? "Upload photo" : "Change photo")
                .font(Theme.Typography.bodySmall)
                .foregroundStyle(Theme.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private var avatar: some View {
        if let image {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .frame(width: 96, height: 96)
                .clipShape(Circle())
        } else {
            Text(draftUser.initials)
                .font(Theme.Typography.headlineMedium)
                .foregroundStyle(Theme.Colors.primary)
                .frame(width: 96, height: 96)
                .background(Theme.Colors.tertiary)
                .clipShape(Circle())
        }
    }

    private var draftUser: User {
        User(
            id: model.user?.id ?? "draft",
            name: name,
            mobileNumber: phone,
            upiId: upiID,
            walletBalance: model.user?.walletBalance ?? 0,
            currency: model.user?.currency ?? "INR",
            photoFile: nil,
            photoUpdatedAt: nil
        )
    }

    private var isDirty: Bool {
        if photoFile != nil { return true }
        guard let user = model.user else {
            return !name.isEmpty || !phone.isEmpty || !upiID.isEmpty
        }
        return name != user.name
            || phone != user.mobileNumber
            || upiID != user.upiId
    }

    private func apply(_ user: User) {
        name = user.name
        phone = user.mobileNumber
        upiID = user.upiId
        image = model.photo
        photoFile = nil
        appliedUserID = user.id
    }

    private func save() async {
        let saved = await model.save(
            name: name,
            mobileNumber: phone,
            upiId: upiID,
            photoFile: photoFile
        )
        if saved, let user = model.user {
            apply(user)
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
        .environment(\.userDetails, UserDetailsViewModel.preview)
}

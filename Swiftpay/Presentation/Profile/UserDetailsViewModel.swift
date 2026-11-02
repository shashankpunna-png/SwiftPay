import Foundation
import UIKit

@Observable
final class UserDetailsViewModel {
    private(set) var user: User?
    private(set) var isRefreshing = false
    private(set) var isSaving = false
    private(set) var loadError: String?
    private(set) var saveError: String?
    private(set) var isShowingCachedProfile = false

    var showsBalanceOnLaunch: Bool {
        didSet { visibility.setShowsBalanceOnLaunch(showsBalanceOnLaunch) }
    }

    var photo: UIImage? {
        guard let photoFile = user?.photoFile,
              let data = Data(base64Encoded: photoFile) else { return nil }
        return UIImage(data: data)
    }

    private let getCachedUser: GetCachedUserUseCase
    private let refreshUser: RefreshUserUseCase
    private let updateUser: UpdateUserUseCase
    private let visibility: BalanceVisibilityStore

    init(
        getCachedUser: GetCachedUserUseCase,
        refreshUser: RefreshUserUseCase,
        updateUser: UpdateUserUseCase,
        balanceVisibility: BalanceVisibilityStore
    ) {
        self.getCachedUser = getCachedUser
        self.refreshUser = refreshUser
        self.updateUser = updateUser
        visibility = balanceVisibility
        showsBalanceOnLaunch = balanceVisibility.showsBalanceOnLaunch
    }

    func load() async {
        if user == nil {
            user = try? await getCachedUser.execute()
        }
        guard !isRefreshing else { return }
        isRefreshing = true
        defer { isRefreshing = false }
        do {
            user = try await refreshUser.execute()
            loadError = nil
            isShowingCachedProfile = false
        } catch {
            loadError = user == nil ? error.localizedDescription : nil
            isShowingCachedProfile = user != nil
        }
    }

    @discardableResult
    func save(
        name: String,
        mobileNumber: String,
        upiId: String,
        photoFile: String?
    ) async -> Bool {
        guard !isSaving else { return false }
        guard let update = validatedUpdate(
            name: name,
            mobileNumber: mobileNumber,
            upiId: upiId,
            photoFile: photoFile
        ) else {
            return false
        }

        isSaving = true
        defer { isSaving = false }
        do {
            user = try await updateUser.execute(update)
            saveError = nil
            loadError = nil
            isShowingCachedProfile = false
            return true
        } catch {
            saveError = error.localizedDescription
            return false
        }
    }

    private func validatedUpdate(
        name: String,
        mobileNumber: String,
        upiId: String,
        photoFile: String?
    ) -> UserUpdate? {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            saveError = "Enter your name."
            return nil
        }
        let digits = mobileNumber.filter(\.isNumber)
        guard digits.count == 10 else {
            saveError = "Enter a 10-digit mobile number."
            return nil
        }
        let upi = upiId.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !upi.isEmpty else {
            saveError = "Enter your UPI ID."
            return nil
        }
        saveError = nil
        return UserUpdate(
            name: trimmedName,
            mobileNumber: digits,
            upiId: upi,
            photoFile: photoFile
        )
    }
}

#if DEBUG
extension UserDetailsViewModel {
    static var preview: UserDetailsViewModel {
        let repository = PreviewUserRepository()
        let model = UserDetailsViewModel(
            getCachedUser: GetCachedUserUseCase(repository: repository),
            refreshUser: RefreshUserUseCase(repository: repository),
            updateUser: UpdateUserUseCase(repository: repository),
            balanceVisibility: BalanceVisibilityStore(defaults: UserDefaults(suiteName: "SwiftPayPreview")!)
        )
        model.user = repository.sample
        return model
    }
}

private final class PreviewUserRepository: UserRepository {
    let sample = User(
        id: "preview-user",
        name: "Aarav Shah",
        mobileNumber: "9876543210",
        upiId: "aarav.shah@swiftpay",
        walletBalance: 12450,
        currency: "INR",
        photoFile: nil,
        photoUpdatedAt: nil
    )

    func cachedUser() async throws -> User? { sample }
    func refreshUser() async throws -> User { sample }
    func updateUser(_ update: UserUpdate) async throws -> User {
        User(
            id: sample.id,
            name: update.name,
            mobileNumber: update.mobileNumber,
            upiId: update.upiId,
            walletBalance: sample.walletBalance,
            currency: "INR",
            photoFile: update.photoFile ?? sample.photoFile,
            photoUpdatedAt: sample.photoUpdatedAt
        )
    }
}
#endif

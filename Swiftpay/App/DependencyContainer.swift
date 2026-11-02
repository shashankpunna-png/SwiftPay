import Foundation
import SwiftData

@MainActor
final class DependencyContainer {
    let modelContainer: ModelContainer
    let userDetails: UserDetailsViewModel

    init() {
        do {
            modelContainer = try UserStore.makeContainer()
        } catch {
            fatalError("Could not open the user store: \(error)")
        }
        let repository = UserRepositoryImpl(
            remote: UserRemoteDataSource(client: .live()),
            store: UserStore(context: modelContainer.mainContext)
        )
        userDetails = UserDetailsViewModel(
            getCachedUser: GetCachedUserUseCase(repository: repository),
            refreshUser: RefreshUserUseCase(repository: repository),
            updateUser: UpdateUserUseCase(repository: repository),
            balanceVisibility: BalanceVisibilityStore()
        )
    }
}

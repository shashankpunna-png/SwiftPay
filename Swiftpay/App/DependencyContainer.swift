
import Foundation
import SwiftData

@MainActor
final class DependencyContainer {
    let modelContainer: ModelContainer
    let userDetails: UserDetailsViewModel
    let transactions: TransactionsViewModel

    init() {
        do {
            modelContainer = try UserStore.makeContainer()
        } catch {
            fatalError("Could not open the user store: \(error)")
        }

        let context = modelContainer.mainContext

        let userRepository = UserRepositoryImpl(
            remote: UserRemoteDataSource(client: .live()),
            store: UserStore(context: context)
        )

        userDetails = UserDetailsViewModel(
            getCachedUser: GetCachedUserUseCase(repository: userRepository),
            refreshUser: RefreshUserUseCase(repository: userRepository),
            updateUser: UpdateUserUseCase(repository: userRepository),
            balanceVisibility: BalanceVisibilityStore()
        )

        let transactionRepository = TransactionRepositoryImpl(
            remote: TransactionRemoteDataSource(client: .live()),
            store: TransactionStore(context: context)
        )

        transactions = TransactionsViewModel(
            getCached: GetCachedTransactionsUseCase(repository: transactionRepository),
            refresh: RefreshTransactionsUseCase(repository: transactionRepository)
        )
    }
}

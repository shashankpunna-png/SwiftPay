import Foundation

final class UserRepositoryImpl: UserRepository {
    private let remote: UserAPI
    private let store: UserStore

    init(remote: UserAPI, store: UserStore) {
        self.remote = remote
        self.store = store
    }

    func cachedUser() async throws -> User? {
        try store.load()
    }

    func refreshUser() async throws -> User {
        let user = try await remote.fetchUser()
        try store.save(user)
        return user
    }

    func updateUser(_ update: UserUpdate) async throws -> User {
        let user = try await remote.updateUser(update)
        try store.save(user)
        return user
    }
}

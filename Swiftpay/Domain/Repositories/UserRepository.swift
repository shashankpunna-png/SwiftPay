import Foundation

protocol UserRepository {
    func cachedUser() async throws -> User?
    func refreshUser() async throws -> User
    func updateUser(_ update: UserUpdate) async throws -> User
}

import Foundation

protocol UserAPI {
    func fetchUser() async throws -> User
    func updateUser(_ update: UserUpdate) async throws -> User
}

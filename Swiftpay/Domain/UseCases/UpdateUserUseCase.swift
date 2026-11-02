import Foundation

struct UpdateUserUseCase {
    private let repository: UserRepository

    init(repository: UserRepository) {
        self.repository = repository
    }

    func execute(_ update: UserUpdate) async throws -> User {
        try await repository.updateUser(update)
    }
}

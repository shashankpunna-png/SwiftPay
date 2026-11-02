import Foundation

struct RefreshUserUseCase {
    private let repository: UserRepository

    init(repository: UserRepository) {
        self.repository = repository
    }

    func execute() async throws -> User {
        try await repository.refreshUser()
    }
}

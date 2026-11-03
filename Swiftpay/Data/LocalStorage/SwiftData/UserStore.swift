import Foundation
import SwiftData

struct UserStore {
    let context: ModelContext

    static func makeContainer(inMemory: Bool = false) throws -> ModelContainer {
        let schema = Schema([
            StoredUser.self,
            StoredTransaction.self
        ])

        let configuration = ModelConfiguration(
            "User",
            schema: schema,
            isStoredInMemoryOnly: inMemory
        )

        return try ModelContainer(
            for: schema,
            configurations: configuration
        )
    }

    func load() throws -> User? {
        var descriptor = FetchDescriptor<StoredUser>()
        descriptor.fetchLimit = 1

        let stored = try context.fetch(descriptor)
        return stored.first?.user
    }

    func save(_ user: User) throws {
        let stored = try context.fetch(FetchDescriptor<StoredUser>())
        if let match = stored.first(where: { $0.id == user.id }) {
            match.fill(from: user)
            for extra in stored where extra.id != user.id {
                context.delete(extra)
            }
        } else {
            for extra in stored {
                context.delete(extra)
            }
            context.insert(StoredUser(user: user))
        }
        try context.save()
    }
}

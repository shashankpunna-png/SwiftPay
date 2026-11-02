import Foundation
import SwiftData

struct UserStore {
    let context: ModelContext

    static func makeContainer(inMemory: Bool = false) throws -> ModelContainer {
        let configuration = ModelConfiguration("User", isStoredInMemoryOnly: inMemory)
        return try ModelContainer(for: StoredUser.self, configurations: configuration)
    }

    func load() throws -> User? {
        let stored = try context.fetch(FetchDescriptor<StoredUser>())
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

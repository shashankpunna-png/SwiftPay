import Foundation

struct UserRemoteDataSource: UserAPI {
    let client: APIClient
    private let encoder = JSONEncoder()

    func fetchUser() async throws -> User {
        let response: UserEnvelope = try await client.send(path: "/api/user", method: "GET")
        return response.user.domainUser()
    }

    func updateUser(_ update: UserUpdate) async throws -> User {
        let body = try encoder.encode(UpdateUserBody(update))
        let response: UserEnvelope = try await client.send(path: "/api/user", method: "PATCH", body: body)
        return response.user.domainUser()
    }
}

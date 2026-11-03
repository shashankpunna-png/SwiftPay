import Foundation

enum APIError: LocalizedError, Equatable {
    case unreachable
    case timedOut
    case server(
        status: Int,
        code: String?,
        message: String
    )
    case undecodable

    var errorDescription: String? {
        switch self {
        case .unreachable:
            return "Connect to the internet and try again."

        case .timedOut:
            return "The request timed out. Try again."

        case .server(_, _, let message):
            return message

        case .undecodable:
            return "The server response could not be read."
        }
    }
}

struct APIFailureBody: Decodable {
    struct Payload: Decodable {
        let code: String?
        let message: String?
    }

    let success: Bool?
    let message: String?
    let error: Payload?
}
import Foundation

enum APIError: LocalizedError, Equatable {
    case unreachable
    case timedOut
    case server(status: Int, message: String)
    case undecodable

    var errorDescription: String? {
        switch self {
        case .unreachable:
            return "Connect to the internet to refresh your profile."
        case .timedOut:
            return "The request timed out. Try again."
        case .server(_, let message):
            return message
        case .undecodable:
            return "The server response could not be read."
        }
    }
}

struct APIFailureBody: Decodable {
    struct Payload: Decodable {
        let message: String
    }

    let error: Payload
}

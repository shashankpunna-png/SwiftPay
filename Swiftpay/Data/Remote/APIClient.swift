import Foundation

struct APIClient {
    var session: URLSession
    var baseURL: URL

    private let decoder = JSONDecoder()

    static func live(baseURL: URL = URL(string: "http://127.0.0.1:4000")!) -> APIClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 30
        configuration.waitsForConnectivity = false
        return APIClient(session: URLSession(configuration: configuration), baseURL: baseURL)
    }

    func send<Response: Decodable>(
        path: String,
        method: String,
        body: Data? = nil
    ) async throws -> Response {
        let data = try await sendData(path: path, method: method, body: body)
        do {
            return try decoder.decode(Response.self, from: data)
        } catch {
            throw APIError.undecodable
        }
    }

    func data(from url: URL) async throws -> Data {
        try await load(request: URLRequest(url: url))
    }

    private func sendData(path: String, method: String, body: Data?) async throws -> Data {
        guard let url = URL(string: path, relativeTo: baseURL)?.absoluteURL else {
            throw APIError.undecodable
        }
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.timeoutInterval = 30
        if let body {
            request.httpBody = body
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        return try await load(request: request)
    }

    private func load(request: URLRequest) async throws -> Data {
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch let error as URLError {
            switch error.code {
            case .timedOut:
                throw APIError.timedOut
            default:
                throw APIError.unreachable
            }
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.unreachable
        }

        guard let http = response as? HTTPURLResponse else {
            throw APIError.undecodable
        }
        guard (200..<300).contains(http.statusCode) else {
            let message = (try? decoder.decode(APIFailureBody.self, from: data))?.error.message
                ?? "The server returned an error."
            throw APIError.server(status: http.statusCode, message: message)
        }
        return data
    }
}

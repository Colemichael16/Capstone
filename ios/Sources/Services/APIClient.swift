import Foundation

enum APIError: Error, LocalizedError {
    case server(message: String)
    case invalidResponse
    case notAuthenticated

    var errorDescription: String? {
        switch self {
        case .server(let message): return message
        case .invalidResponse: return "Unexpected response from the server."
        case .notAuthenticated: return "You need to sign in first."
        }
    }
}

/// Thin JSON HTTP client for the db/ backend. See shared/api-contract.md
/// for every route and shape this talks to. `token` is set by `AuthStore`
/// once the user signs in and attached as a bearer token to any request
/// with `requiresAuth: true`.
final class APIClient {
    private let baseURL: URL
    private let session: URLSession
    var token: String?

    init(baseURL: URL = AppConfig.apiBaseURL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }

    func request<Body: Encodable, Response: Decodable>(
        _ path: String,
        method: String = "GET",
        body: Body,
        requiresAuth: Bool = false
    ) async throws -> Response {
        var urlRequest = URLRequest(url: baseURL.appendingPathComponent(path))
        urlRequest.httpMethod = method
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if requiresAuth {
            guard let token else { throw APIError.notAuthenticated }
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        urlRequest.httpBody = try JSONEncoder().encode(body)

        return try await perform(urlRequest)
    }

    func request<Response: Decodable>(
        _ path: String,
        method: String = "GET",
        requiresAuth: Bool = false
    ) async throws -> Response {
        var urlRequest = URLRequest(url: baseURL.appendingPathComponent(path))
        urlRequest.httpMethod = method

        if requiresAuth {
            guard let token else { throw APIError.notAuthenticated }
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        return try await perform(urlRequest)
    }

    private func perform<Response: Decodable>(_ request: URLRequest) async throws -> Response {
        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw APIError.invalidResponse }

        guard (200..<300).contains(http.statusCode) else {
            if let decoded = try? JSONDecoder().decode(ServerErrorBody.self, from: data) {
                throw APIError.server(message: decoded.error)
            }
            throw APIError.invalidResponse
        }

        return try JSONDecoder.api.decode(Response.self, from: data)
    }
}

private struct ServerErrorBody: Decodable { let error: String }

import Foundation

struct AuthResponse: Decodable {
    let token: String
    let user: User
}

private struct RegisterRequest: Encodable {
    let email: String
    let password: String
    let name: String
}

private struct LoginRequest: Encodable {
    let email: String
    let password: String
}

/// Talks to `/api/auth/*`. See shared/api-contract.md.
final class AuthService {
    private let client: APIClient

    init(client: APIClient) {
        self.client = client
    }

    func register(email: String, password: String, name: String) async throws -> AuthResponse {
        try await client.request(
            "/api/auth/register",
            method: "POST",
            body: RegisterRequest(email: email, password: password, name: name)
        )
    }

    func login(email: String, password: String) async throws -> AuthResponse {
        try await client.request(
            "/api/auth/login",
            method: "POST",
            body: LoginRequest(email: email, password: password)
        )
    }
}

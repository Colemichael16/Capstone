import Foundation

/// Session state: who's signed in, and the `APIClient` carrying their
/// token. Restores a saved session from the Keychain on launch so users
/// aren't signed out every time the app relaunches.
@MainActor
final class AuthStore: ObservableObject {
    @Published private(set) var currentUser: User?
    @Published private(set) var isAuthenticating = false
    @Published var errorMessage: String?

    let client: APIClient
    private let authService: AuthService

    private static let tokenKey = "authToken"
    private static let userKey = "authUser"

    var isAuthenticated: Bool { currentUser != nil }

    init(client: APIClient = APIClient()) {
        self.client = client
        self.authService = AuthService(client: client)

        if let token = KeychainStore.get(forKey: Self.tokenKey),
           let userJSON = KeychainStore.get(forKey: Self.userKey),
           let userData = userJSON.data(using: .utf8),
           let user = try? JSONDecoder().decode(User.self, from: userData) {
            client.token = token
            currentUser = user
        }
    }

    func register(email: String, password: String, name: String) async {
        await run { try await self.authService.register(email: email, password: password, name: name) }
    }

    func login(email: String, password: String) async {
        await run { try await self.authService.login(email: email, password: password) }
    }

    func logout() {
        client.token = nil
        currentUser = nil
        KeychainStore.remove(forKey: Self.tokenKey)
        KeychainStore.remove(forKey: Self.userKey)
    }

    private func run(_ operation: @escaping () async throws -> AuthResponse) async {
        errorMessage = nil
        isAuthenticating = true
        defer { isAuthenticating = false }

        do {
            let response = try await operation()
            client.token = response.token
            currentUser = response.user
            KeychainStore.set(response.token, forKey: Self.tokenKey)
            if let userData = try? JSONEncoder().encode(response.user),
               let userJSON = String(data: userData, encoding: .utf8) {
                KeychainStore.set(userJSON, forKey: Self.userKey)
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

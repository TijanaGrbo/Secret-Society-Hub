import Foundation

protocol AuthService {
    func login(username: String, password: String) async throws -> String
}

enum AuthError: Error {
    case invalidCredentials
    case missingToken

    var description: String {
        switch self {
        case .invalidCredentials:
            return "Username or password is incorrect"
        case .missingToken:
            return "Could not fetch the token"
        }
    }
}

//
// MARK: - Network implementation
//

/// Production implementation of `AuthService`
final class AuthAPIService: AuthService {
    private let baseURL = URL(string: "https://example.com")!

    func login(username: String, password: String) async throws -> String {
        var request = URLRequest(url: baseURL.appendingPathComponent("/api/login"))
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: String] = [
            "username": username,
            "password": password
        ]
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)

        // Validate HTTP status
        guard let http = response as? HTTPURLResponse,
              (200..<300).contains(http.statusCode) else {
            throw AuthError.invalidCredentials
        }

        let decoded = try JSONDecoder().decode(LoginResponse.self, from: data)
        return decoded.token
    }
}

//
// MARK: - Mock implementation
//

/// Mock implementation used for development and previews.
final class MockAuthService: AuthService {
    func login(username: String, password: String) async throws -> String {
        // Simulated network delay
        try await Task.sleep(nanoseconds: 300_000_000)

        guard !username.isEmpty, !password.isEmpty else {
            throw AuthError.invalidCredentials
        }

        guard let url = Bundle.main.url(forResource: "login", withExtension: "json") else {
            throw AuthError.missingToken
        }

        let data = try Data(contentsOf: url)
        let response = try JSONDecoder().decode(LoginResponse.self, from: data)
        return response.token
    }
}

import Foundation

protocol UserService {
    func fetchUsers(token: String) async throws -> [User]
}

enum UserServiceError: Error {
    case unauthorized
    case missingData

    var description: String {
        switch self {
        case .unauthorized:
            return "You're not logged in"
        case .missingData:
            return "Could not fetch the data"
        }
    }
}

//
// MARK: - Network implementation
//

final class UserAPIService: UserService {
    private let baseURL = URL(string: "https://example.com")!

    func fetchUsers(token: String) async throws -> [User] {
        guard !token.isEmpty else {
            throw UserServiceError.unauthorized
        }

        var request = URLRequest(url: baseURL.appendingPathComponent("/api/users"))
        request.httpMethod = "GET"
        request.addValue(token, forHTTPHeaderField: "x-auth-token")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let http = response as? HTTPURLResponse,
              (200..<300).contains(http.statusCode) else {
            if (response as? HTTPURLResponse)?.statusCode == 401 {
                throw UserServiceError.unauthorized
            } else {
                throw UserServiceError.missingData
            }
        }

        let decoded = try JSONDecoder().decode(UsersResponse.self, from: data)
        return decoded.data
    }
}

//
// MARK: - Mock implementation
//

final class MockUserService: UserService {
    func fetchUsers(token: String) async throws -> [User] {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 300_000_000)

        guard !token.isEmpty else {
            throw UserServiceError.unauthorized
        }

        guard let url = Bundle.main.url(forResource: "users", withExtension: "json") else {
            throw UserServiceError.missingData
        }

        let data = try Data(contentsOf: url)
        let response = try JSONDecoder().decode(UsersResponse.self, from: data)
        return response.data
    }
}

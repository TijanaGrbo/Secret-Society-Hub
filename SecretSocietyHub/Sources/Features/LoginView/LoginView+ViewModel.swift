import Foundation
import Combine

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var username = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let authService: AuthService

    init(authService: AuthService) {
        self.authService = authService
    }

    #if DEBUG
    /// Convenience initializer for previews and development.
    convenience init() {
        self.init(authService: MockAuthService())
    }
    #endif


    var canSubmit: Bool {
        !username.isEmpty && !password.isEmpty && !isLoading
    }

    /// This login flow only does basic client-side checks.
    /// In a real application, credentials would be validated on a backend
    /// and errors surfaced more accurately.
    func login() async -> String? {
        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        do {
            let token = try await authService.login(username: username, password: password)
            return token
        } catch let authError as AuthError {
            errorMessage = authError.description
            return nil
        } catch {
            errorMessage = "Login failed"
            return nil
        }
    }
}

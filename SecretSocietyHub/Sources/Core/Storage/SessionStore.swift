import Foundation
import Combine

/// Notes:
/// The session token is persisted using `@KeychainStored`, but the UI reacts to changes
/// through `@Published`.
@MainActor
final class SessionStore: ObservableObject {
    /// Securely persisted authentication token stored in the Keychain.
    @KeychainStored(key: "auth_token")
    private var storedToken: String?

    /// The `didSet` ensures the value is also saved to Keychain.
    @Published var authToken: String? {
        didSet {
            storedToken = authToken
        }
    }

    /// Computed directly from `authToken` to avoid duplicated state.
    var isLoggedIn: Bool {
        authToken != nil
    }

    init() {
        authToken = storedToken
    }

    func setToken(_ token: String?) {
        authToken = token
    }
}

// MARK: - Preview Helper

#if DEBUG
extension SessionStore {
    /// Provides a preconfigured `SessionStore` instance for SwiftUI previews.
    static func preview() -> SessionStore {
        let session = SessionStore()
        session.setToken("preview-token")
        return session
    }
}
#endif

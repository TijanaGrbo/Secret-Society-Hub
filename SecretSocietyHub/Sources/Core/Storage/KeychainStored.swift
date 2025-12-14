import Foundation
import Security

/// This wrapper abstracts away the verbose Keychain API
@propertyWrapper
struct KeychainStored {

    enum KeychainError: Error, LocalizedError {
        case unexpectedStatus(OSStatus)
        case invalidData

        var errorDescription: String? {
            switch self {
            case .unexpectedStatus(let status):
                if let message = SecCopyErrorMessageString(status, nil) as String? {
                    return "Keychain error (\(status)): \(message)"
                } else {
                    return "Keychain error with status: \(status)"
                }
            case .invalidData:
                return "Invalid data in Keychain item."
            }
        }
    }

    private let key: String
    private let service: String
    private let accessible: CFString

    init(
        key: String,
        service: String = Bundle.main.bundleIdentifier ?? "KeychainService",
        accessible: CFString = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
    ) {
        self.key = key
        self.service = service
        self.accessible = accessible
    }

    /// The wrapped value exposed to callers.
    var wrappedValue: String? {
        get {
            do { return try read() }
            catch { return nil }
        }
        set {
            // TODO: Handle errors
            if let newValue {
                try? write(newValue)
            } else {
                try? delete()
            }
        }
    }

    // MARK: - Keychain operations

    private func read() throws -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        switch status {
        case errSecSuccess:
            guard let data = item as? Data else { throw KeychainError.invalidData }
            return String(data: data, encoding: .utf8)

        case errSecItemNotFound:
            return nil

        default:
            throw KeychainError.unexpectedStatus(status)
        }
    }

    private func write(_ value: String) throws {
        let encoded = Data(value.utf8)

        var query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]

        let attributesToUpdate: [String: Any] = [
            kSecValueData as String: encoded,
            kSecAttrAccessible as String: accessible
        ]

        let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)

        switch status {
        case errSecSuccess:
            return

        case errSecItemNotFound:
            query[kSecValueData as String] = encoded
            query[kSecAttrAccessible as String] = accessible

            let addStatus = SecItemAdd(query as CFDictionary, nil)
            guard addStatus == errSecSuccess else {
                throw KeychainError.unexpectedStatus(addStatus)
            }

        default:
            throw KeychainError.unexpectedStatus(status)
        }
    }

    private func delete() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]

        let status = SecItemDelete(query as CFDictionary)

        switch status {
        case errSecSuccess,
             errSecItemNotFound:
            return

        default:
            throw KeychainError.unexpectedStatus(status)
        }
    }
}

//
//  SecureStore.swift
//  KeychainToken
//
//  Created by Dmytro Mazalov on 21.09.2025.
//

import Foundation
import Security
import LocalAuthentication

public protocol SecureStoring {
    func set(_ data: Data, for key: String) throws
    func get(for key: String) throws -> Data?
    func delete(_ key: String) throws
    func deleteAll() throws
}

public struct KeychainError: Error, LocalizedError {
    public let status: OSStatus
    public var errorDescription: String? {
        SecCopyErrorMessageString(status, nil) as String? ?? "Keychain error \(status)"
    }
}

public final class SecureStore: SecureStoring {
    private let service: String
    private let queue = DispatchQueue(label: "com.appname.securestore")
    private var cache: [String: Data] = [:]

    public init(service: String = "com.appname.securestore") {
        self.service = service
    }

    // MARK: Public API
    public func set(_ data: Data, for key: String) throws {
        try queue.sync {
            try keychainDelete(key: key)
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: key,
                kSecValueData as String: data,
                // "ThisDeviceOnly" to avoid backups; safer for auth tokens
                kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
            ]
            let status = SecItemAdd(query as CFDictionary, nil)
            guard status == errSecSuccess else { throw KeychainError(status: status) }
            cache[key] = data
        }
    }

    public func get(for key: String) throws -> Data? {
        try queue.sync {
            if let cached = cache[key] { return cached }
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: key,
                kSecReturnData as String: true,
                kSecMatchLimit as String: kSecMatchLimitOne
            ]
            var item: CFTypeRef?
            let status = SecItemCopyMatching(query as CFDictionary, &item)
            if status == errSecItemNotFound { return nil }
            guard status == errSecSuccess else { throw KeychainError(status: status) }
            let data = item as? Data
            cache[key] = data
            return data
        }
    }

    public func delete(_ key: String) throws {
        try queue.sync {
            try keychainDelete(key: key)
            cache.removeValue(forKey: key)
        }
    }

    public func deleteAll() throws {
        try queue.sync {
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service
            ]
            let status = SecItemDelete(query as CFDictionary)
            guard status == errSecSuccess || status == errSecItemNotFound else {
                throw KeychainError(status: status)
            }
            cache.removeAll()
        }
    }

    // MARK: Helpers
    private func keychainDelete(key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError(status: status)
        }
    }
}

/// Biometric-protected variant that conforms to the same protocol.
/// Items are written with SecAccessControl(userPresence) and reads will prompt with Face ID / Touch ID.
public final class SecureStoreBiometric: SecureStoring {
    private let service: String
    private let queue = DispatchQueue(label: "com.appname.securestore.biometric")

    public init(service: String = "com.appname.securestore.biometric") {
        self.service = service
    }

    public func set(_ data: Data, for key: String) throws {
        try queue.sync {
            _ = try? delete(key)
            var error: Unmanaged<CFError>?
            guard let access = SecAccessControlCreateWithFlags(nil,
                                                               kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
                                                               [.userPresence],
                                                               &error) else {
                throw error!.takeRetainedValue() as Error
            }
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: key,
                kSecValueData as String: data,
                kSecAttrAccessControl as String: access
            ]
            let status = SecItemAdd(query as CFDictionary, nil)
            guard status == errSecSuccess else { throw KeychainError(status: status) }
        }
    }

    public func get(for key: String) throws -> Data? {
        try queue.sync {
            let ctx = LAContext()
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: key,
                kSecReturnData as String: true,
                kSecMatchLimit as String: kSecMatchLimitOne,
                kSecUseAuthenticationContext as String: ctx,
                kSecUseOperationPrompt as String: "Authenticate to access secure data"
            ]
            var item: CFTypeRef?
            let status = SecItemCopyMatching(query as CFDictionary, &item)
            if status == errSecItemNotFound { return nil }
            guard status == errSecSuccess else { throw KeychainError(status: status) }
            return item as? Data
        }
    }

    public func delete(_ key: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key
        ]
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError(status: status)
        }
    }

    public func deleteAll() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service
        ]
        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError(status: status)
        }
    }
}

//
//  TokenManager.swift
//  KeychainToken
//
//  Created by Dmytro Mazalov on 21.09.2025.
//

import Foundation

public protocol TokenManaging {
    func getAccessToken() -> String?
    func getLastAccessToken() -> String?
    func setAccessToken(_ token: String?) throws
    func clearAccessToken() throws

    func getAnyOtherValue() -> String?
    func setAnyOtherValue(_ value: String?) throws
    func clearAnyOtherValue() throws

    func clearAll() throws
}

public final class TokenManager: TokenManaging {
    public enum Key: String {
        case access     = "access_token"
        case lastAccess = "last_access_token"
        
        case otherValue = "other_value"
    }
    
    private let store: any SecureStoring
    
    public init(store: any SecureStoring = SecureStore(service: "ua.od.vilki-palki.auth")) {
        self.store = store
    }
    
    // MARK: Access Token
    public func getAccessToken() -> String? {
        (try? store.get(for: Key.access.rawValue))
            .flatMap { String(data: $0, encoding: .utf8) }
    }
    
    public func getLastAccessToken() -> String? {
        (try? store.get(for: Key.lastAccess.rawValue))
            .flatMap { String(data: $0, encoding: .utf8) }
    }
    
    public func setAccessToken(_ token: String?) throws {
        if let token, let data = token.data(using: .utf8) {
            try store.set(data, for: Key.access.rawValue)
            try store.set(data, for: Key.lastAccess.rawValue)
        } else {
            try store.delete(Key.access.rawValue)
        }
    }
    
    public func clearAccessToken() throws {
        try store.delete(Key.access.rawValue)
    }
    
    // MARK: Other Value
    public func getAnyOtherValue() -> String? {
        (try? store.get(for: Key.otherValue.rawValue))
            .flatMap { String(data: $0, encoding: .utf8) }
    }
    
    public func setAnyOtherValue(_ value: String?) throws {
        if let value, let data = value.data(using: .utf8) {
            try store.set(data, for: Key.otherValue.rawValue)
        } else {
            try store.delete(Key.otherValue.rawValue)
        }
    }
    
    public func clearAnyOtherValue() throws {
        try store.delete(Key.otherValue.rawValue)
    }
    
    // MARK: Clear All
    public func clearAll() throws {
        try store.deleteAll()
    }
}

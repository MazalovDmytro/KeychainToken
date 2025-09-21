//
//  MockStore.swift
//  KeychainToken
//
//  Created by Мазалов Дмитрий on 21.09.2025.
//

import XCTest
@testable import KeychainToken

final class MockStore: SecureStoring {
    private var storage: [String: Data] = [:]
    private let queue = DispatchQueue(label: "tests.securestore.inmemory")

    func set(_ data: Data, for key: String) throws {
        queue.sync { storage[key] = data }
    }

    func get(for key: String) throws -> Data? {
        queue.sync { storage[key] }
    }

    func delete(_ key: String) throws {
        queue.sync { storage[key] = nil }
    }

    func deleteAll() throws {
        queue.sync { storage.removeAll() }
    }
}

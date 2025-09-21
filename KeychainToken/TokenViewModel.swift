//
//  TokenViewModel.swift
//  KeychainToken
//
//  Created by Dmytro Mazalov on 21.09.2025.
//

import Foundation
import Combine

final class TokenViewModel: ObservableObject {
    @Published var inputToken: String = ""
    @Published var status: String = "Unknown"
    @Published var masked: String? = nil
    @Published var message: String? = nil

    private let manager: TokenManaging

    init(manager: TokenManaging) {
        self.manager = manager
        refresh()
    }

    func refresh() {
        if let token = manager.getAccessToken() {
            masked = Self.mask(token)
            status = "Stored"
        } else {
            masked = nil
            status = "Not stored"
        }
    }

    func save() {
        do {
            try manager.setAccessToken(inputToken.isEmpty ? nil : inputToken)
            inputToken = ""
            message = "Saved"
            refresh()
        } catch {
            message = error.localizedDescription
        }
    }

    func deleteToken() {
        do {
            try manager.clearAccessToken()
            message = "Deleted"
            refresh()
        } catch {
            message = error.localizedDescription
        }
    }

    func authenticateAndRead() {
        if let token = manager.getAccessToken() {
            masked = Self.mask(token)
            message = "Authenticated"
            status = "Stored"
        } else if let lastToken = manager.getLastAccessToken() {
            masked = Self.mask(lastToken)
            message = "Authenticated by previos token"
            status = "Stored previos token"
        } else {
            masked = nil
            status = "Not stored"
            message = "No token"
        }
    }

    private static func mask(_ token: String) -> String {
        guard token.count > 6 else {
            return String(repeating: "•", count: max(0, token.count - 2)) + token.suffix(2)
        }
        return "••••••••" + token.suffix(4)
    }
}

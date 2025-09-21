//
//  KeychainTokenApp.swift
//  KeychainToken
//
//  Created by Dmytro Mazalov on 21.09.2025.
//

import SwiftUI

@main
struct KeychainTokenApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(
                vm: TokenViewModel(
                    manager: TokenManager(store: SecureStore())
                )
            )
        }
    }
}

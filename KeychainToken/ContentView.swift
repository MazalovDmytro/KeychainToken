//
//  ContentView.swift
//  KeychainToken
//
//  Created by Dmytro Mazalov on 21.09.2025.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var vm: TokenViewModel

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Status")) {
                    HStack {
                        Text("Token:")
                        Spacer()
                        Text(vm.status).foregroundColor(.secondary)
                    }
                    if let m = vm.masked {
                        LabeledContent("Masked") { Text(m).font(.body.monospacedDigit()) }
                        Button("Read (Face ID)") { vm.authenticateAndRead() }
                    } else {
                        Button("Authenticate with Face ID") { vm.authenticateAndRead() }
                    }
                }

                Section(header: Text("Save / Update")) {
                    SecureField("Session token", text: $vm.inputToken)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                    Button("Save token") { vm.save() }
                        .disabled(vm.inputToken.isEmpty)
                }

                Section {
                    Button(role: .destructive) { vm.deleteToken() } label: {
                        Text("Delete token")
                    }
                }

                if let msg = vm.message {
                    Section { Text(msg).foregroundColor(.secondary) }
                }
            }
            .navigationTitle("Keychain Token")
        }
    }
}

#Preview {
    ContentView(vm: TokenViewModel(manager: TokenManager(store: SecureStore())))
}

# KeychainTokenAuth (TokenManager-based)

SwiftUI sample app that demonstrates storing an **access token** in the **Keychain**, with optional **Face ID / Touch ID** protection.  
It builds on a `TokenManager` abstraction and supports interchangeable storage backends (`SecureStore` for simple storage, `SecureStoreBiometric` for biometric-protected storage).

---

## Features
- **SecureStore** — baseline Keychain store with thread safety and in-memory cache
- **SecureStoreBiometric** — uses `SecAccessControl(.userPresence)` so reads require Face ID / Touch ID (or passcode)
- **TokenManager** — simple API to get/set/clear access tokens
- **SwiftUI UI**:
  - Save a token
  - Delete a token
  - Authenticate & read a token with Face ID / Touch ID
- **Unit tests**:
  - Test the `TokenManager` with `SecureStore` (non-biometric) to avoid prompts

---

## Project Structure
```
Sources/
 ├── App.swift                # SwiftUI App entry
 ├── ContentView.swift        # Main UI
 ├── TokenViewModel           # ViewModel for UI
 └── ├── SecureStore.swift    # SecureStore & SecureStoreBiometric
     └── TokenManager.swift   # TokenManager API
Tests/
 ├── KeychainTokenTests.swift
 └── MockStore.swift
```

---

## Example Usage
```swift
let manager = TokenManager(store: SecureStoreBiometric())
try? manager.setAccessToken("my-secret-token")

if let token = manager.getAccessToken() {
    print("Got token: \(token)")
}
```

---

## Notes
- For testing, use `SecureStore` (no biometry) so tests can run without user interaction.
- Tokens are stored with **ThisDeviceOnly** accessibility, which prevents them from being restored from backups.

---

## License
Free to use for learning and demo purposes.

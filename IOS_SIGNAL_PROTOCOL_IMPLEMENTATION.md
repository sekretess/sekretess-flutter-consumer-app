# iOS Signal Protocol Implementation

## Overview
The Signal Protocol is implemented for iOS using native Swift code bridged via Platform Channels, mirroring the Android implementation.

## Architecture

### Flutter Side
- **`CryptographicService`** (`lib/data/services/cryptographic_service.dart`)
  - Same Flutter service used for both Android and iOS
  - Uses Platform Channel `"io.sekretess/signal_protocol"`
  - Automatically routes to the correct platform implementation

### iOS Native Side

#### 1. Platform Channel Bridge
- **`AppDelegate.swift`** - Sets up Platform Channels on app launch
- **`SignalProtocolHandler.swift`** - Handles Platform Channel calls and delegates to `SekretessCryptographicService`

#### 2. Core Signal Protocol Service
- **`SekretessCryptographicService.swift`** - Main Signal Protocol implementation
  - `init()` - Initializes keys, generates KeyBundle, uploads to server
  - `decryptGroupChatMessage()` - Decrypts group chat messages using GroupCipher
  - `decryptPrivateMessage()` - Decrypts private messages using SessionCipher
  - `processKeyDistributionMessage()` - Processes key distribution for group chats
  - `updateOneTimeKeys()` - Updates one-time prekeys

#### 3. Signal Protocol Store
- **`SekretessSignalProtocolStore.swift`** - Implements `SignalProtocolStore` protocol
  - Manages all Signal Protocol state (keys, sessions, identities)
  - Delegates to specialized stores:
    - `SekretessIdentityKeyStore` - Identity keys
    - `SekretessPreKeyStore` - One-time prekeys
    - `SekretessSignedPreKeyStore` - Signed prekeys
    - `SekretessKyberPreKeyStore` - Post-quantum keys
    - `SekretessSessionStore` - Session records
    - `SekretessSenderKeyStore` - Group sender keys

#### 4. Data Persistence
- **Core Data** (`SekretessDatabase.swift`) - Stores all Signal Protocol data
- **Repositories** (`Repositories.swift`) - Data access layer for each key type:
  - `IdentityKeyRepository`
  - `PreKeyRepository`
  - `SignedPreKeyRepository`
  - `KyberPreKeyRepository`
  - `SessionRepository`
  - `SenderKeyRepository`
  - `RegistrationRepository`

#### 5. API Bridge
- **`FlutterDependencyProvider.swift`** - Sets up API callback for native-to-Flutter calls
- **`ApiBridgeService.dart`** (Flutter) - Handles API calls from native code (shared with Android)
- **`KeyBundleConverter.swift`** - Converts native KeyBundle to Map for Flutter

## Complete Flow

### Initialization
```
MainPage.initState()
  → CryptographicService.init() (Flutter)
    → PlatformChannel.invokeMethod('init')
      → SignalProtocolHandler.handleMethodCall() (Swift)
        → SekretessCryptographicService.init() (Swift)
          → Checks if registration required
          → Generates KeyBundle if needed
          → Calls FlutterDependencyProvider.callApi()
            → AppDelegate API bridge callback
              → ApiBridgeService (Flutter)
                → ApiClient.upsertKeyStore()
                  → HTTP PUT to server
```

### Message Decryption
```
WebSocket receives encrypted message
  → MessageService.handleMessage()
    → CryptographicService.decrypt*Message() (Flutter)
      → PlatformChannel.invokeMethod('decrypt*Message')
        → SignalProtocolHandler.handleMethodCall() (Swift)
          → SekretessCryptographicService.decrypt*Message() (Swift)
            → SessionCipher/GroupCipher.decrypt()
              → Returns decrypted message
                → MessageRepository.storeDecryptedMessage()
                  → MessageDatabase.insertMessage()
```

## Dependencies

### Podfile
```ruby
pod 'SignalClient', '~> 0.80.0'
```

## Files Structure

```
ios/Runner/
├── AppDelegate.swift
├── SignalProtocolHandler.swift
├── FlutterDependencyProvider.swift
├── SekretessCryptographicService.swift
├── SekretessSignalProtocolStore.swift
├── KeyBundle.swift
├── KeyBundleConverter.swift
├── SekretessDatabase.swift
├── Repositories.swift
└── Stores.swift
```

## Status

### ✅ Completed
- Platform Channel setup
- Signal Protocol handler
- Cryptographic service structure
- Signal Protocol Store structure
- Repository structure
- API bridge setup
- Key bundle conversion

### ⚠️ TODO (Implementation Details)
- Complete Core Data model definitions
- Implement repository methods with actual Core Data queries
- Verify SignalClient Swift API matches implementation
- Add error handling for edge cases
- Test end-to-end flow

## Notes

1. **SignalClient Library**: The actual SignalClient Swift API may differ from the Java version. The implementation structure is in place, but API calls may need adjustment based on the actual library.

2. **Core Data**: Repository implementations are stubbed and need to be completed with actual Core Data queries.

3. **Testing**: The implementation follows the same pattern as Android but needs testing to ensure compatibility with the SignalClient Swift library.

## Next Steps

1. Verify SignalClient pod installation
2. Complete Core Data model implementation
3. Implement repository methods
4. Test initialization flow
5. Test message decryption
6. Verify API bridge functionality

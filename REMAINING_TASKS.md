# Remaining Tasks

## ✅ Completed

### Android
- ✅ Signal Protocol implementation complete
- ✅ MethodChannel bridge working
- ✅ API bridge for native-to-Flutter calls
- ✅ Message database (Drift) implemented
- ✅ End-to-end flow working

### iOS
- ✅ Platform Channel setup
- ✅ Signal Protocol handler structure
- ✅ Cryptographic service structure
- ✅ Signal Protocol Store structure
- ✅ Repository structure
- ✅ Store implementations structure
- ✅ API bridge setup

## ⚠️ Remaining Tasks

### iOS Implementation (High Priority)

#### 1. Install SignalClient Pod
```bash
cd ios
pod install
```
**Status**: SignalClient pod is referenced in Podfile but not yet installed (not in Podfile.lock)

#### 2. Create Core Data Model
**File**: `ios/Runner/SekretessDatabase.xcdatamodeld`

**Entities needed** (based on Android Room entities):
- `IdentityKeyEntity` - Store identity keys
- `IdentityKeyPairEntity` - Store identity key pairs
- `RegistrationIdEntity` - Store registration ID
- `PreKeyRecordEntity` - Store one-time prekeys
- `SignedPreKeyRecordEntity` - Store signed prekeys
- `KyberPreKeyEntity` - Store post-quantum keys
- `SessionEntity` - Store session records
- `SenderKeyEntity` - Store sender keys for group chats

**Attributes for each entity** (match Android Room entities):
- See Android entities in `app/src/main/java/io/sekretess/db/model/` for reference

#### 3. Implement Repository Methods
**File**: `ios/Runner/Repositories.swift`

**TODOs to implement** (currently 20+ stubbed methods):
- `IdentityKeyRepository.getIdentityKeyPair()` - Core Data fetch
- `IdentityKeyRepository.storeIdentityKeyPair()` - Core Data save
- `PreKeyRepository.getPreKey()` - Core Data fetch
- `PreKeyRepository.storePreKey()` - Core Data save
- `PreKeyRepository.count()` - Core Data count query
- All other repository methods (see file for complete list)

#### 4. Verify SignalClient API
**Files**: 
- `ios/Runner/SekretessCryptographicService.swift`
- `ios/Runner/SekretessSignalProtocolStore.swift`
- `ios/Runner/Stores.swift`

**Action**: The SignalClient Swift API may differ from the Java version. Need to:
- Verify actual SignalClient Swift API
- Adjust method calls to match actual API
- Update imports and type names if needed

#### 5. Complete Store Implementations
**File**: `ios/Runner/Stores.swift`

**TODOs**:
- `SekretessIdentityKeyStore.saveIdentity()` - Implement identity saving logic
- `SekretessIdentityKeyStore.isTrustedIdentity()` - Implement trust check
- `SekretessIdentityKeyStore.getIdentity()` - Implement identity retrieval

#### 6. Update SekretessDatabase.swift
**File**: `ios/Runner/SekretessDatabase.swift`

**Action**: Ensure Core Data model name matches the `.xcdatamodeld` file name

### Testing & Verification

#### 7. Test iOS Build
```bash
cd ios
pod install
flutter build ios --debug
```

#### 8. Test Signal Protocol Initialization
- Verify `init()` method works
- Check key generation
- Verify API bridge calls Flutter correctly

#### 9. Test Message Decryption
- Test group chat message decryption
- Test private message decryption
- Verify messages are stored in database

#### 10. End-to-End Testing
- Test complete flow: WebSocket → Decryption → Storage
- Test key updates
- Test key distribution messages

## Priority Order

1. **Install SignalClient pod** (blocks everything else)
2. **Create Core Data model** (required for repositories)
3. **Implement repository methods** (required for stores)
4. **Verify SignalClient API** (may need code adjustments)
5. **Complete store implementations** (finalize logic)
6. **Test and fix issues** (verify everything works)

## Notes

- The Android implementation is **fully complete** and working
- The iOS implementation has the **complete structure** but needs:
  - Actual Core Data implementation
  - SignalClient library integration
  - API verification and adjustments
- The Flutter side (`CryptographicService`) works for both platforms automatically

## Estimated Effort

- Core Data model creation: ~1-2 hours
- Repository implementation: ~3-4 hours
- SignalClient API verification: ~1-2 hours
- Testing and fixes: ~2-3 hours
- **Total**: ~7-11 hours of development work

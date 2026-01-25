import Foundation
import LibSignalClient

/// Signal Protocol Store implementation for iOS.
/// Aggregates all Signal Protocol stores and manages all Signal Protocol state.
class SekretessSignalProtocolStore {
    let identityKeyStore: SekretessIdentityKeyStore
    let preKeyStore: SekretessPreKeyStore
    let sessionStore: SekretessSessionStore
    let signedPreKeyStore: SekretessSignedPreKeyStore
    let senderKeyStore: SekretessSenderKeyStore
    let kyberPreKeyStore: SekretessKyberPreKeyStore
    private let minKeysThreshold = 5
    
    init(
        identityKeyRepository: IdentityKeyRepository,
        registrationRepository: RegistrationRepository,
        preKeyRepository: PreKeyRepository,
        signedPreKeyRepository: SignedPreKeyRepository,
        sessionRepository: SessionRepository,
        senderKeyRepository: SenderKeyRepository,
        kyberPreKeyRepository: KyberPreKeyRepository
    ) {
        self.identityKeyStore = SekretessIdentityKeyStore(
            identityKeyRepository: identityKeyRepository,
            registrationRepository: registrationRepository
        )
        self.preKeyStore = SekretessPreKeyStore(preKeyRepository: preKeyRepository)
        self.sessionStore = SekretessSessionStore(sessionRepository: sessionRepository)
        self.signedPreKeyStore = SekretessSignedPreKeyStore(
            preKeyRepository: preKeyRepository,
            signedPreKeyRepository: signedPreKeyRepository
        )
        self.senderKeyStore = SekretessSenderKeyStore(senderKeyRepository: senderKeyRepository)
        self.kyberPreKeyStore = SekretessKyberPreKeyStore(kyberPreKeyRepository: kyberPreKeyRepository)
        
        print("SekretessSignalProtocolStore: SignalProtocolStore initialized")
    }
    
    func registrationRequired() -> Bool {
        let required = identityKeyStore.registrationRequired()
        print("SekretessSignalProtocolStore: registrationRequired: \(required)")
        return required
    }
    
    func updateKeysRequired() -> Bool {
        return preKeyStore.count() <= minKeysThreshold
    }
    
    func clearStorage() {
        identityKeyStore.clearStorage()
        preKeyStore.clearStorage()
        sessionStore.clearStorage()
        signedPreKeyStore.clearStorage()
        senderKeyStore.clearStorage()
        kyberPreKeyStore.clearStorage()
    }
    
    // MARK: - SignalProtocolStore Protocol Implementation
    
    func getIdentityKeyPair() -> IdentityKeyPair {
        return identityKeyStore.getIdentityKeyPair()
    }
    
    func getLocalRegistrationId() -> UInt32 {
        return identityKeyStore.getLocalRegistrationId()
    }
    
    func saveIdentity(_ address: ProtocolAddress, _ identity: IdentityKey) -> IdentityChange {
        return identityKeyStore.saveIdentity(address, identity)
    }
    
    func isTrustedIdentity(_ address: ProtocolAddress, _ identity: IdentityKey, _ direction: Direction) -> Bool {
        return identityKeyStore.isTrustedIdentity(address, identity, direction)
    }
    
    func getIdentity(_ address: ProtocolAddress) -> IdentityKey? {
        return identityKeyStore.getIdentity(address)
    }
    
    func loadPreKey(id: UInt32) throws -> PreKeyRecord {
        return try preKeyStore.loadPreKey(id: id)
    }
    
    func storePreKey(_ id: UInt32, _ record: PreKeyRecord) {
        preKeyStore.storePreKey(id, record)
    }
    
    func removePreKey(_ id: UInt32) {
        preKeyStore.removePreKey(id)
    }
    
    func loadSignedPreKey(id: UInt32) throws -> SignedPreKeyRecord {
        return try signedPreKeyStore.loadSignedPreKey(id: id)
    }
    
    func storeSignedPreKey(_ id: UInt32, _ record: SignedPreKeyRecord) {
        signedPreKeyStore.storeSignedPreKey(id, record)
    }
    
    func removeSignedPreKey(_ id: UInt32) {
        signedPreKeyStore.removeSignedPreKey(id)
    }
    
    func loadKyberPreKey(id: UInt32) throws -> KyberPreKeyRecord {
        return try kyberPreKeyStore.loadKyberPreKey(id: id)
    }
    
    func storeKyberPreKey(_ id: UInt32, _ record: KyberPreKeyRecord) {
        kyberPreKeyStore.storeKyberPreKey(id, record)
    }
    
    func removeKyberPreKey(_ id: UInt32) {
        kyberPreKeyStore.removeKyberPreKey(id)
    }
    
    func loadKyberPreKeys() -> [KyberPreKeyRecord] {
        return kyberPreKeyStore.loadKyberPreKeys()
    }
    
    func containsKyberPreKey(_ id: UInt32) -> Bool {
        return kyberPreKeyStore.containsKyberPreKey(id)
    }
    
    func markKyberPreKeyUsed(_ id: UInt32) {
        kyberPreKeyStore.markKyberPreKeyUsed(id)
    }
    
    func loadSession(for address: ProtocolAddress) -> SessionRecord? {
        return try? sessionStore.loadSession(for: address, context: SimpleStoreContext())
    }
    
    func loadExistingSessions(for addresses: [ProtocolAddress]) throws -> [SessionRecord] {
        return try sessionStore.loadExistingSessions(for: addresses, context: SimpleStoreContext())
    }
    
    func getSubDeviceSessions(name: String) -> [UInt32] {
        return sessionStore.getSubDeviceSessions(name: name)
    }
    
    func containsSession(_ address: ProtocolAddress) -> Bool {
        return sessionStore.containsSession(address)
    }
    
    func deleteAllSessions(name: String) {
        sessionStore.deleteAllSessions(name: name)
    }
    
    func loadSignedPreKeys() -> [SignedPreKeyRecord] {
        return signedPreKeyStore.loadSignedPreKeys()
    }
    
    func containsSignedPreKey(_ id: UInt32) -> Bool {
        return signedPreKeyStore.containsSignedPreKey(id)
    }
    
    func containsPreKey(_ id: UInt32) -> Bool {
        return preKeyStore.containsPreKey(id)
    }
    
    func storeSession(_ address: ProtocolAddress, _ record: SessionRecord) {
        do {
            try sessionStore.storeSession(record, for: address, context: SimpleStoreContext())
        } catch {
            print("Error storing session: \(error)")
        }
    }
    
    func removeSession(for address: ProtocolAddress) {
        sessionStore.removeSession(for: address)
    }
    
    func loadSenderKey(for distributionId: UUID, senderName: String, deviceId: UInt32) -> SenderKeyRecord? {
        do {
            let address = try ProtocolAddress(name: senderName, deviceId: deviceId)
            return try senderKeyStore.loadSenderKey(from: address, distributionId: distributionId, context: SimpleStoreContext())
        } catch {
            print("Error loading sender key: \(error)")
            return nil
        }
    }
    
    func storeSenderKey(_ distributionId: UUID, _ address: ProtocolAddress, _ record: SenderKeyRecord) {
        do {
            try senderKeyStore.storeSenderKey(from: address, distributionId: distributionId, record: record, context: SimpleStoreContext())
        } catch {
            print("Error storing sender key: \(error)")
        }
    }
}

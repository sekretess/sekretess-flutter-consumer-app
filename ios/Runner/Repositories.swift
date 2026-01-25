import Foundation
import SwiftData
import LibSignalClient

// MARK: - Base Repository Protocol
@available(iOS 17.0, *)
protocol Repository {
    var database: SekretessDatabase { get }
}

// MARK: - Helper Extensions
// Note: Data already has base64EncodedString() and init?(base64Encoded:) in Foundation
// No need for custom extensions

// MARK: - Identity Key Repository
@available(iOS 17.0, *)
class IdentityKeyRepository: Repository {
    let database: SekretessDatabase
    
    init(database: SekretessDatabase) {
        self.database = database
    }
    
    func getIdentityKeyPair() -> IdentityKeyPair? {
        let context = database.viewContext
        var descriptor = FetchDescriptor<IdentityKeyPairEntity>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        descriptor.fetchLimit = 1
        
        do {
            let results: [IdentityKeyPairEntity] = try context.fetch(descriptor)
            if let entity = results.first,
               let keyData = Data(base64Encoded: entity.identityKeyPair) {
                return try IdentityKeyPair(bytes: keyData)
            }
        } catch {
            print("Error fetching identity key pair: \(error)")
        }
        return nil
    }
    
    func storeIdentityKeyPair(_ keyPair: IdentityKeyPair) {
        let context = database.viewContext
        
        do {
            let serialized = try keyPair.serialize()
            let entity = IdentityKeyPairEntity(
                identityKeyPair: serialized.base64EncodedString(),
                createdAt: Int64(Date().timeIntervalSince1970)
            )
            context.insert(entity)
            try context.save()
        } catch {
            print("Error storing identity key pair: \(error)")
        }
    }
    
    func getIdentityKey(deviceId: Int32, name: String) -> IdentityKeyEntity? {
        let context = database.viewContext
        var descriptor = FetchDescriptor<IdentityKeyEntity>(
            predicate: #Predicate { entity in
                entity.deviceId == deviceId && entity.name == name
            }
        )
        descriptor.fetchLimit = 1
        
        do {
            let results: [IdentityKeyEntity] = try context.fetch(descriptor)
            return results.first
        } catch {
            print("Error fetching identity key: \(error)")
            return nil
        }
    }
    
    func saveIdentity(deviceId: Int32, name: String, identityKey: IdentityKey) -> IdentityChange {
        let context = database.viewContext
        
        if let existing = getIdentityKey(deviceId: deviceId, name: name) {
            do {
                let serialized = try identityKey.serialize()
                existing.identityKey = serialized.base64EncodedString()
                try context.save()
                return .replacedExisting
            } catch {
                print("Error updating identity key: \(error)")
                return .newOrUnchanged
            }
        } else {
            do {
                let serialized = try identityKey.serialize()
                let entity = IdentityKeyEntity(
                    deviceId: deviceId,
                    name: name,
                    identityKey: serialized.base64EncodedString(),
                    createdAt: Int64(Date().timeIntervalSince1970)
                )
                context.insert(entity)
                try context.save()
                return .newOrUnchanged
            } catch {
                print("Error storing identity key: \(error)")
                return .newOrUnchanged
            }
        }
    }
    
    func getIdentity(deviceId: Int32, name: String) -> IdentityKey? {
        guard let entity = getIdentityKey(deviceId: deviceId, name: name),
              let keyData = Data(base64Encoded: entity.identityKey) else {
            return nil
        }
        
        do {
            return try IdentityKey(bytes: keyData)
        } catch {
            print("Error deserializing identity key: \(error)")
            return nil
        }
    }
    
    func clearStorage() {
        let context = database.viewContext
        
        do {
            // Delete identity key pairs
            let pairDescriptor = FetchDescriptor<IdentityKeyPairEntity>()
            let pairs = try context.fetch(pairDescriptor)
            for pair in pairs {
                context.delete(pair)
            }
            
            // Delete identity keys
            let keyDescriptor = FetchDescriptor<IdentityKeyEntity>()
            let keys = try context.fetch(keyDescriptor)
            for key in keys {
                context.delete(key)
            }
            
            try context.save()
        } catch {
            print("Error clearing identity key storage: \(error)")
        }
    }
}

// MARK: - Registration Repository
@available(iOS 17.0, *)
class RegistrationRepository: Repository {
    let database: SekretessDatabase
    
    init(database: SekretessDatabase) {
        self.database = database
    }
    
    func getRegistrationId() -> UInt32? {
        let context = database.viewContext
        var descriptor = FetchDescriptor<RegistrationIdEntity>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        descriptor.fetchLimit = 1
        
        do {
            let results: [RegistrationIdEntity] = try context.fetch(descriptor)
            if let entity = results.first {
                let id = UInt32(entity.registrationId)
                // Registration ID must be between 1 and 255
                // If it's 0 or > 255, treat it as invalid and delete the entity
                if id == 0 || id > 255 {
                    context.delete(entity)
                    try context.save()
                    return nil
                }
                return id
            }
        } catch {
            print("Error fetching registration ID: \(error)")
        }
        return nil
    }
    
    func storeRegistrationId(_ id: UInt32) {
        let context = database.viewContext
        
        do {
            // Delete existing registration IDs
            let descriptor = FetchDescriptor<RegistrationIdEntity>()
            let existing = try context.fetch(descriptor)
            for entity in existing {
                context.delete(entity)
            }
            
            // Insert new one
            let entity = RegistrationIdEntity(
                registrationId: Int64(id),
                createdAt: Int64(Date().timeIntervalSince1970)
            )
            context.insert(entity)
            try context.save()
        } catch {
            print("Error storing registration ID: \(error)")
        }
    }
}

// MARK: - Pre Key Repository
@available(iOS 17.0, *)
class PreKeyRepository: Repository {
    let database: SekretessDatabase
    
    init(database: SekretessDatabase) {
        self.database = database
    }
    
    func getPreKey(id: UInt32) -> PreKeyRecord? {
        let idValue = Int64(id)
        let context = database.viewContext
        var descriptor = FetchDescriptor<PreKeyRecordEntity>(
            predicate: #Predicate { entity in
                entity.preKeyId == idValue
            }
        )
        descriptor.fetchLimit = 1
        
        do {
            let results: [PreKeyRecordEntity] = try context.fetch(descriptor)
            if let entity = results.first,
               let keyData = Data(base64Encoded: entity.preKeyRecord) {
                return try PreKeyRecord(bytes: keyData)
            }
        } catch {
            print("Error fetching pre key: \(error)")
        }
        return nil
    }
    
    func storePreKey(_ id: UInt32, _ record: PreKeyRecord) {
        let idValue = Int64(id)
        let context = database.viewContext
        
        do {
            // Check if exists and update, otherwise insert
            var descriptor = FetchDescriptor<PreKeyRecordEntity>(
                predicate: #Predicate { entity in
                    entity.preKeyId == idValue
                }
            )
            descriptor.fetchLimit = 1
            let results: [PreKeyRecordEntity] = try context.fetch(descriptor)
            let entity: PreKeyRecordEntity
            
            if let existing = results.first {
                entity = existing
            } else {
                entity = PreKeyRecordEntity(
                    preKeyId: idValue,
                    preKeyRecord: "",
                    createdAt: Int64(Date().timeIntervalSince1970)
                )
                context.insert(entity)
            }
            
            let serialized = try record.serialize()
            entity.preKeyRecord = serialized.base64EncodedString()
            entity.used = false
            entity.createdAt = Int64(Date().timeIntervalSince1970)
            
            try context.save()
        } catch {
            print("Error storing pre key: \(error)")
        }
    }
    
    func removePreKey(_ id: UInt32) {
        let idValue = Int64(id)
        let context = database.viewContext
        let descriptor = FetchDescriptor<PreKeyRecordEntity>(
            predicate: #Predicate { entity in
                entity.preKeyId == idValue
            }
        )
        
        do {
            let results: [PreKeyRecordEntity] = try context.fetch(descriptor)
            for entity in results {
                context.delete(entity)
            }
            try context.save()
        } catch {
            print("Error removing pre key: \(error)")
        }
    }
    
    func count() -> Int {
        let context = database.viewContext
        let descriptor = FetchDescriptor<PreKeyRecordEntity>()
        
        do {
            return try context.fetchCount(descriptor)
        } catch {
            print("Error counting pre keys: \(error)")
            return 0
        }
    }
    
    func clearStorage() {
        let context = database.viewContext
        let descriptor = FetchDescriptor<PreKeyRecordEntity>()
        
        do {
            let results: [PreKeyRecordEntity] = try context.fetch(descriptor)
            for entity in results {
                context.delete(entity)
            }
            try context.save()
        } catch {
            print("Error clearing pre key storage: \(error)")
        }
    }
}

// MARK: - Signed Pre Key Repository
@available(iOS 17.0, *)
class SignedPreKeyRepository: Repository {
    let database: SekretessDatabase
    
    init(database: SekretessDatabase) {
        self.database = database
    }
    
    func getSignedPreKey(id: UInt32) -> SignedPreKeyRecord? {
        let idValue = Int64(id)
        let context = database.viewContext
        var descriptor = FetchDescriptor<SignedPreKeyRecordEntity>(
            predicate: #Predicate { entity in
                entity.spkId == idValue
            }
        )
        descriptor.fetchLimit = 1
        
        do {
            let results: [SignedPreKeyRecordEntity] = try context.fetch(descriptor)
            if let entity = results.first,
               let keyData = Data(base64Encoded: entity.spkRecord) {
                return try SignedPreKeyRecord(bytes: keyData)
            }
        } catch {
            print("Error fetching signed pre key: \(error)")
        }
        return nil
    }
    
    func storeSignedPreKey(_ id: UInt32, _ record: SignedPreKeyRecord) {
        let idValue = Int64(id)
        let context = database.viewContext
        
        do {
            var descriptor = FetchDescriptor<SignedPreKeyRecordEntity>(
                predicate: #Predicate { entity in
                    entity.spkId == idValue
                }
            )
            descriptor.fetchLimit = 1
            let results: [SignedPreKeyRecordEntity] = try context.fetch(descriptor)
            let entity: SignedPreKeyRecordEntity
            
            if let existing = results.first {
                entity = existing
            } else {
                entity = SignedPreKeyRecordEntity(
                    spkId: idValue,
                    spkRecord: "",
                    createdAt: Int64(Date().timeIntervalSince1970)
                )
                context.insert(entity)
            }
            
            let serialized = try record.serialize()
            entity.spkRecord = serialized.base64EncodedString()
            entity.used = false
            entity.createdAt = Int64(Date().timeIntervalSince1970)
            
            try context.save()
        } catch {
            print("Error storing signed pre key: \(error)")
        }
    }
    
    func removeSignedPreKey(_ id: UInt32) {
        let idValue = Int64(id)
        let context = database.viewContext
        let descriptor = FetchDescriptor<SignedPreKeyRecordEntity>(
            predicate: #Predicate { entity in
                entity.spkId == idValue
            }
        )
        
        do {
            let results: [SignedPreKeyRecordEntity] = try context.fetch(descriptor)
            for entity in results {
                context.delete(entity)
            }
            try context.save()
        } catch {
            print("Error removing signed pre key: \(error)")
        }
    }
}

// MARK: - Kyber Pre Key Repository
@available(iOS 17.0, *)
class KyberPreKeyRepository: Repository {
    let database: SekretessDatabase
    
    init(database: SekretessDatabase) {
        self.database = database
    }
    
    func getKyberPreKey(id: UInt32) -> KyberPreKeyRecord? {
        let idValue = Int64(id)
        let context = database.viewContext
        var descriptor = FetchDescriptor<KyberPreKeyEntity>(
            predicate: #Predicate { entity in
                entity.prekeyId == idValue
            }
        )
        descriptor.fetchLimit = 1
        
        do {
            let results: [KyberPreKeyEntity] = try context.fetch(descriptor)
            if let entity = results.first,
               let keyData = Data(base64Encoded: entity.kpkRecord) {
                return try KyberPreKeyRecord(bytes: keyData)
            }
        } catch {
            print("Error fetching kyber pre key: \(error)")
        }
        return nil
    }
    
    func storeKyberPreKey(_ id: UInt32, _ record: KyberPreKeyRecord) {
        let idValue = Int64(id)
        let context = database.viewContext
        
        do {
            var descriptor = FetchDescriptor<KyberPreKeyEntity>(
                predicate: #Predicate { entity in
                    entity.prekeyId == idValue
                }
            )
            descriptor.fetchLimit = 1
            let results: [KyberPreKeyEntity] = try context.fetch(descriptor)
            let entity: KyberPreKeyEntity
            
            if let existing = results.first {
                entity = existing
            } else {
                entity = KyberPreKeyEntity(
                    prekeyId: idValue,
                    kpkRecord: "",
                    createdAt: Int64(Date().timeIntervalSince1970)
                )
                context.insert(entity)
            }
            
            let serialized = try record.serialize()
            entity.kpkRecord = serialized.base64EncodedString()
            entity.used = false
            entity.createdAt = Int64(Date().timeIntervalSince1970)
            
            try context.save()
        } catch {
            print("Error storing kyber pre key: \(error)")
        }
    }
    
    func removeKyberPreKey(_ id: UInt32) {
        let idValue = Int64(id)
        let context = database.viewContext
        let descriptor = FetchDescriptor<KyberPreKeyEntity>(
            predicate: #Predicate { entity in
                entity.prekeyId == idValue
            }
        )
        
        do {
            let results: [KyberPreKeyEntity] = try context.fetch(descriptor)
            for entity in results {
                context.delete(entity)
            }
            try context.save()
        } catch {
            print("Error removing kyber pre key: \(error)")
        }
    }
    
    func clearStorage() {
        let context = database.viewContext
        let descriptor = FetchDescriptor<KyberPreKeyEntity>()
        
        do {
            let results: [KyberPreKeyEntity] = try context.fetch(descriptor)
            for entity in results {
                context.delete(entity)
            }
            try context.save()
        } catch {
            print("Error clearing kyber pre key storage: \(error)")
        }
    }
}

// MARK: - Session Repository
@available(iOS 17.0, *)
class SessionRepository: Repository {
    let database: SekretessDatabase
    
    init(database: SekretessDatabase) {
        self.database = database
    }
    
    func getSession(name: String, deviceId: UInt32) -> SessionRecord? {
        let context = database.viewContext
        let nameValue = name
        let deviceIdValue = Int32(deviceId)
        var descriptor = FetchDescriptor<SessionEntity>(
            predicate: #Predicate { entity in
                entity.addressName == nameValue && entity.deviceId == deviceIdValue
            }
        )
        descriptor.fetchLimit = 1
        
        do {
            let results: [SessionEntity] = try context.fetch(descriptor)
            if let entity = results.first,
               let sessionData = Data(base64Encoded: entity.session) {
                return try SessionRecord(bytes: sessionData)
            }
        } catch {
            print("Error fetching session: \(error)")
        }
        return nil
    }
    
    func storeSession(_ name: String, _ deviceId: UInt32, _ record: SessionRecord) {
        let context = database.viewContext
        
        do {
            let nameValue = name
            let deviceIdValue = Int32(deviceId)
            let descriptor = FetchDescriptor<SessionEntity>(
                predicate: #Predicate { entity in
                    entity.addressName == nameValue && entity.deviceId == deviceIdValue
                }
            )
            let results: [SessionEntity] = try context.fetch(descriptor)
            let entity: SessionEntity
            
            if let existing = results.first {
                entity = existing
            } else {
                entity = SessionEntity(
                    addressName: name,
                    deviceId: Int32(deviceId),
                    session: "",
                    createdAt: Int64(Date().timeIntervalSince1970)
                )
                context.insert(entity)
            }
            
            let serialized = try record.serialize()
            entity.session = serialized.base64EncodedString()
            entity.serviceId = nil // Can be set if needed
            entity.createdAt = Int64(Date().timeIntervalSince1970)
            
            try context.save()
        } catch {
            print("Error storing session: \(error)")
        }
    }
    
    func removeSession(_ name: String, _ deviceId: UInt32) {
        let context = database.viewContext
        let nameValue = name
        let deviceIdValue = Int32(deviceId)
        let descriptor = FetchDescriptor<SessionEntity>(
            predicate: #Predicate { entity in
                entity.addressName == nameValue && entity.deviceId == deviceIdValue
            }
        )
        
        do {
            let results: [SessionEntity] = try context.fetch(descriptor)
            for entity in results {
                context.delete(entity)
            }
            try context.save()
        } catch {
            print("Error removing session: \(error)")
        }
    }
    
    func clearStorage() {
        let context = database.viewContext
        let descriptor = FetchDescriptor<SessionEntity>()
        
        do {
            let results: [SessionEntity] = try context.fetch(descriptor)
            for entity in results {
                context.delete(entity)
            }
            try context.save()
        } catch {
            print("Error clearing session storage: \(error)")
        }
    }
}

// MARK: - Sender Key Repository
@available(iOS 17.0, *)
class SenderKeyRepository: Repository {
    let database: SekretessDatabase
    
    init(database: SekretessDatabase) {
        self.database = database
    }
    
    func getSenderKey(distributionId: UUID, name: String, deviceId: UInt32) -> SenderKeyRecord? {
        let context = database.viewContext
        let nameValue = name
        let deviceIdValue = Int32(deviceId)
        let distributionUuidString = distributionId.uuidString
        var descriptor = FetchDescriptor<SenderKeyEntity>(
            predicate: #Predicate { entity in
                entity.addressName == nameValue && entity.deviceId == deviceIdValue && entity.distributionUuid == distributionUuidString
            }
        )
        descriptor.fetchLimit = 1
        
        do {
            let results: [SenderKeyEntity] = try context.fetch(descriptor)
            if let entity = results.first,
               let keyData = Data(base64Encoded: entity.senderKeyRecord) {
                return try SenderKeyRecord(bytes: keyData)
            }
        } catch {
            print("Error fetching sender key: \(error)")
        }
        return nil
    }
    
    func storeSenderKey(_ distributionId: UUID, _ name: String, _ deviceId: UInt32, _ record: SenderKeyRecord) {
        let context = database.viewContext
        let distributionUuidString = distributionId.uuidString
        
        let nameValue = name
        let deviceIdValue = Int32(deviceId)
        do {
            let descriptor = FetchDescriptor<SenderKeyEntity>(
                predicate: #Predicate { entity in
                    entity.addressName == nameValue && entity.deviceId == deviceIdValue && entity.distributionUuid == distributionUuidString
                }
            )
            let results: [SenderKeyEntity] = try context.fetch(descriptor)
            let entity: SenderKeyEntity
            
            if let existing = results.first {
                entity = existing
            } else {
                entity = SenderKeyEntity(
                    addressName: name,
                    deviceId: Int32(deviceId),
                    distributionUuid: distributionUuidString,
                    senderKeyRecord: "",
                    createdAt: Int64(Date().timeIntervalSince1970)
                )
                context.insert(entity)
            }
            
            let serialized = try record.serialize()
            entity.senderKeyRecord = serialized.base64EncodedString()
            entity.createdAt = Int64(Date().timeIntervalSince1970)
            
            try context.save()
        } catch {
            print("Error storing sender key: \(error)")
        }
    }
    
    func clearStorage() {
        let context = database.viewContext
        let descriptor = FetchDescriptor<SenderKeyEntity>()
        
        do {
            let results: [SenderKeyEntity] = try context.fetch(descriptor)
            for entity in results {
                context.delete(entity)
            }
            try context.save()
        } catch {
            print("Error clearing sender key storage: \(error)")
        }
    }
}

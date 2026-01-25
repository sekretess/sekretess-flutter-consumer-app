import Foundation
import SwiftData

// MARK: - SwiftData Models

// All models require iOS 17.0+ for SwiftData
@Model
public class IdentityKeyPairEntity {
    public var id: Int64
    var identityKeyPair: String
    var createdAt: Int64
    
    init(id: Int64 = 0, identityKeyPair: String, createdAt: Int64) {
        self.id = id
        self.identityKeyPair = identityKeyPair
        self.createdAt = createdAt
    }
}

@Model
public class IdentityKeyEntity {
    public var id: Int64
    var deviceId: Int32
    var name: String
    var identityKey: String
    var createdAt: Int64
    
    init(id: Int64 = 0, deviceId: Int32, name: String, identityKey: String, createdAt: Int64) {
        self.id = id
        self.deviceId = deviceId
        self.name = name
        self.identityKey = identityKey
        self.createdAt = createdAt
    }
}

@Model
public class RegistrationIdEntity {
    public var id: Int64
    var registrationId: Int64
    var createdAt: Int64
    
    init(id: Int64 = 0, registrationId: Int64, createdAt: Int64) {
        self.id = id
        self.registrationId = registrationId
        self.createdAt = createdAt
    }
}

@Model
public class PreKeyRecordEntity {
    public var id: Int64
    var preKeyId: Int64
    var preKeyRecord: String
    var used: Bool
    var createdAt: Int64
    
    init(id: Int64 = 0, preKeyId: Int64, preKeyRecord: String, used: Bool = false, createdAt: Int64) {
        self.id = id
        self.preKeyId = preKeyId
        self.preKeyRecord = preKeyRecord
        self.used = used
        self.createdAt = createdAt
    }
}

@Model
public class SignedPreKeyRecordEntity {
    public var id: Int64
    var spkId: Int64
    var spkRecord: String
    var used: Bool
    var createdAt: Int64
    
    init(id: Int64 = 0, spkId: Int64, spkRecord: String, used: Bool = false, createdAt: Int64) {
        self.id = id
        self.spkId = spkId
        self.spkRecord = spkRecord
        self.used = used
        self.createdAt = createdAt
    }
}

@Model
public class KyberPreKeyEntity {
    public var id: Int64
    var prekeyId: Int64
    var kpkRecord: String
    var used: Bool
    var createdAt: Int64
    
    init(id: Int64 = 0, prekeyId: Int64, kpkRecord: String, used: Bool = false, createdAt: Int64) {
        self.id = id
        self.prekeyId = prekeyId
        self.kpkRecord = kpkRecord
        self.used = used
        self.createdAt = createdAt
    }
}

@Model
public class SessionEntity {
    public var id: Int64
    var addressName: String
    var deviceId: Int32
    var session: String
    var serviceId: String?
    var createdAt: Int64
    
    init(id: Int64 = 0, addressName: String, deviceId: Int32, session: String, serviceId: String? = nil, createdAt: Int64) {
        self.id = id
        self.addressName = addressName
        self.deviceId = deviceId
        self.session = session
        self.serviceId = serviceId
        self.createdAt = createdAt
    }
}

@Model
public class SenderKeyEntity {
    public var id: Int64
    var addressName: String
    var deviceId: Int32
    var distributionUuid: String
    var senderKeyRecord: String
    var createdAt: Int64
    
    init(id: Int64 = 0, addressName: String, deviceId: Int32, distributionUuid: String, senderKeyRecord: String, createdAt: Int64) {
        self.id = id
        self.addressName = addressName
        self.deviceId = deviceId
        self.distributionUuid = distributionUuid
        self.senderKeyRecord = senderKeyRecord
        self.createdAt = createdAt
    }
}

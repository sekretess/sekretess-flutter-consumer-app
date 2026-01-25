import Foundation
import LibSignalClient

/// Key bundle containing all Signal Protocol keys for registration
struct KeyBundle {
    let registrationId: UInt32
    let opk: [PreKeyRecord]
    let signedPreKeyRecord: SignedPreKeyRecord
    let identityKeyPair: IdentityKeyPair
    let signature: Data
    let kyberPreKeyRecords: [KyberPreKeyRecord]
}

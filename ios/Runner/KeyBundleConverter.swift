import Foundation
import LibSignalClient

/// Converts native KeyBundle objects to Maps that can be sent to Flutter via MethodChannel
class KeyBundleConverter {
    static func toMap(keyBundle: KeyBundle) -> [String: Any] {
        var map: [String: Any] = [:]
        
        map["RegID"] = keyBundle.registrationId
        map["ik"] = keyBundle.identityKeyPair.publicKey.serialize().base64EncodedString()
        do {
            map["spk"] = try keyBundle.signedPreKeyRecord.publicKey().serialize().base64EncodedString()
        } catch {
            print("Error serializing signed pre key public key: \(error)")
        }
        map["spkID"] = String(keyBundle.signedPreKeyRecord.id)
        map["SPKSignature"] = keyBundle.signature.base64EncodedString()
        
        // Serialize one-time prekeys
        var opk: [String] = []
        for preKey in keyBundle.opk {
            do {
                let publicKeyData = try preKey.publicKey().serialize()
                let publicKeyBase64 = publicKeyData.base64EncodedString()
                opk.append("\(preKey.id):\(publicKeyBase64)")
            } catch {
                print("Error serializing pre key: \(error)")
            }
        }
        map["opk"] = opk
        
        // Serialize post-quantum keys
        let kyberRecords = keyBundle.kyberPreKeyRecords
        guard let lastKyberRecord = kyberRecords.last else {
            return map
        }
        
        // OPQK (all except last)
        var opqk: [String] = []
        for kyberRecord in kyberRecords.dropLast() {
            do {
                let keyPair = try kyberRecord.keyPair()
                let publicKeyData = keyPair.publicKey.serialize()
                let publicKeyBase64 = publicKeyData.base64EncodedString()
                let signatureBase64 = kyberRecord.signature.base64EncodedString()
                opqk.append("\(kyberRecord.id):\(publicKeyBase64):\(signatureBase64)")
            } catch {
                print("Error serializing kyber pre key: \(error)")
            }
        }
        map["OPQK"] = opqk
        
        // PQSPK (last resort key)
        do {
            let keyPair = try lastKyberRecord.keyPair()
            let publicKeyData = keyPair.publicKey.serialize()
            let publicKeyBase64 = publicKeyData.base64EncodedString()
            let signatureBase64 = lastKyberRecord.signature.base64EncodedString()
            map["PQSPK"] = "\(lastKyberRecord.id):\(publicKeyBase64):\(signatureBase64)"
            map["PQSPKID"] = String(lastKyberRecord.id)
            map["PQSPKSignature"] = signatureBase64
        } catch {
            print("Error serializing last kyber pre key: \(error)")
        }
        
        return map
    }
    
    static func oneTimeKeysToMap(preKeyRecords: [PreKeyRecord], kyberPreKeyRecords: [KyberPreKeyRecord]) -> [String: Any] {
        var map: [String: Any] = [:]
        
        // Serialize prekeys
        var opk: [String] = []
        for preKey in preKeyRecords {
            do {
                let publicKeyData = try preKey.publicKey().serialize()
                let publicKeyBase64 = publicKeyData.base64EncodedString()
                opk.append("\(preKey.id):\(publicKeyBase64)")
            } catch {
                print("Error serializing pre key: \(error)")
            }
        }
        map["OPK"] = opk
        
        // Serialize kyber prekeys (all except last)
        var opqk: [String] = []
        for kyberRecord in kyberPreKeyRecords.dropLast() {
            do {
                let keyPair = try kyberRecord.keyPair()
                let publicKeyData = keyPair.publicKey.serialize()
                let publicKeyBase64 = publicKeyData.base64EncodedString()
                let signatureBase64 = kyberRecord.signature.base64EncodedString()
                opqk.append("\(kyberRecord.id):\(publicKeyBase64):\(signatureBase64)")
            } catch {
                print("Error serializing kyber pre key: \(error)")
            }
        }
        map["OPQK"] = opqk
        
        return map
    }
}

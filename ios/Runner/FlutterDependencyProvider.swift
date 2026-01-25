import Foundation
import UIKit
import LibSignalClient

/// Dependency provider for Flutter app's native Signal Protocol components on iOS.
/// Similar to FlutterDependencyProvider on Android but adapted for iOS/Swift.
class FlutterDependencyProvider {
    private static var cryptographicService: SekretessCryptographicService?
    private static var signalProtocolStore: SekretessSignalProtocolStore?
    private static var apiCallback: ((String, [String: Any]?) -> Bool)?
    
    static func initialize() {
        // Initialize database
        let database = SekretessDatabase.shared
        
        // Initialize repositories
        let identityKeyRepository = IdentityKeyRepository(database: database)
        let registrationRepository = RegistrationRepository(database: database)
        let preKeyRepository = PreKeyRepository(database: database)
        let signedPreKeyRepository = SignedPreKeyRepository(database: database)
        let sessionRepository = SessionRepository(database: database)
        let senderKeyRepository = SenderKeyRepository(database: database)
        let kyberPreKeyRepository = KyberPreKeyRepository(database: database)
        
        // Initialize Signal Protocol Store
        signalProtocolStore = SekretessSignalProtocolStore(
            identityKeyRepository: identityKeyRepository,
            registrationRepository: registrationRepository,
            preKeyRepository: preKeyRepository,
            signedPreKeyRepository: signedPreKeyRepository,
            sessionRepository: sessionRepository,
            senderKeyRepository: senderKeyRepository,
            kyberPreKeyRepository: kyberPreKeyRepository
        )
        
        // Initialize Cryptographic Service
        guard let store = signalProtocolStore else {
            fatalError("Failed to initialize Signal Protocol Store")
        }
        
        cryptographicService = SekretessCryptographicService(signalProtocolStore: store)
        
        print("FlutterDependencyProvider initialized")
    }
    
    static func getCryptographicService() -> SekretessCryptographicService {
        guard let service = cryptographicService else {
            fatalError("FlutterDependencyProvider not initialized. Call initialize() first.")
        }
        return service
    }
    
    static func setApiCallback(_ callback: @escaping (String, [String: Any]?) -> Bool) {
        apiCallback = callback
    }
    
    static func callApi(method: String, arguments: [String: Any]?) -> Bool {
        guard let callback = apiCallback else {
            print("API callback not set")
            return false
        }
        return callback(method, arguments)
    }
    
    static func getApplicationContext() -> Any {
        // Return UIApplication for compatibility
        return UIApplication.shared
    }
}

package io.sekretess.bridge;

import android.content.Context;
import android.util.Log;

import io.sekretess.cryptography.storage.SekretessSignalProtocolStore;
import io.sekretess.db.SekretessDatabase;
import io.sekretess.db.repository.IdentityKeyRepository;
import io.sekretess.db.repository.KyberPreKeyRepository;
import io.sekretess.db.repository.PreKeyRepository;
import io.sekretess.db.repository.RegistrationRepository;
import io.sekretess.db.repository.SenderKeyRepository;
import io.sekretess.db.repository.SessionRepository;
import io.sekretess.db.repository.SignedPreKeyRepository;
import io.sekretess.service.SekretessCryptographicService;

/**
 * Dependency provider for Flutter app's native Signal Protocol components.
 * Similar to SekretessDependencyProvider but adapted for Flutter.
 */
public class FlutterDependencyProvider {
    private static final String TAG = "FlutterDependencyProvider";
    
    private static SekretessCryptographicService cryptographicService;
    private static SekretessSignalProtocolStore signalProtocolStore;
    private static NativeApiClientBridge apiClientBridge;
    private static Context applicationContext;
    
    public static void initialize(Context context) {
        // Prevent double initialization
        if (applicationContext != null && cryptographicService != null) {
            Log.i(TAG, "FlutterDependencyProvider already initialized, skipping");
            return;
        }
        
        applicationContext = context.getApplicationContext();
        
        // Initialize database
        SekretessDatabase database = SekretessDatabase.getInstance(applicationContext);
        
        // Initialize repositories (they will get database instance internally)
        IdentityKeyRepository identityKeyRepository = new IdentityKeyRepository();
        RegistrationRepository registrationRepository = new RegistrationRepository();
        PreKeyRepository preKeyRepository = new PreKeyRepository();
        SignedPreKeyRepository signedPreKeyRepository = new SignedPreKeyRepository();
        SessionRepository sessionRepository = new SessionRepository();
        SenderKeyRepository senderKeyRepository = new SenderKeyRepository();
        KyberPreKeyRepository kyberPreKeyRepository = new KyberPreKeyRepository();
        
        // Initialize Signal Protocol Store
        signalProtocolStore = new SekretessSignalProtocolStore(
            identityKeyRepository,
            registrationRepository,
            preKeyRepository,
            signedPreKeyRepository,
            sessionRepository,
            senderKeyRepository,
            kyberPreKeyRepository
        );
        
        // Initialize API client bridge
        apiClientBridge = new NativeApiClientBridge(applicationContext);
        
        // Initialize Cryptographic Service
        cryptographicService = new SekretessCryptographicService(signalProtocolStore);
        cryptographicService.setApiClientBridge(apiClientBridge);
        
        Log.i(TAG, "FlutterDependencyProvider initialized");
    }
    
    public static SekretessCryptographicService getCryptographicService() {
        if (cryptographicService == null) {
            throw new IllegalStateException("FlutterDependencyProvider not initialized. Call initialize() first.");
        }
        return cryptographicService;
    }
    
    public static NativeApiClientBridge getApiClientBridge() {
        if (apiClientBridge == null) {
            throw new IllegalStateException("FlutterDependencyProvider not initialized. Call initialize() first.");
        }
        return apiClientBridge;
    }
    
    public static Context getApplicationContext() {
        if (applicationContext == null) {
            throw new IllegalStateException("FlutterDependencyProvider not initialized. Call initialize() first.");
        }
        return applicationContext;
    }
    
    // Static method for compatibility with repository constructors
    public static Context applicationContext() {
        return getApplicationContext();
    }
}

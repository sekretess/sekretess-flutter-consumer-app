package io.sekretess

import android.content.Context
import android.util.Log
import io.sekretess.bridge.FlutterDependencyProvider
import io.sekretess.service.SekretessCryptographicService
import java.util.Optional

/**
 * Handler for Signal Protocol operations.
 * This class bridges Flutter MethodChannel calls to the native Signal Protocol implementation.
 */
class SignalProtocolHandler(private val context: Context) {
    private val TAG = "SignalProtocolHandler"
    private var initialized = false
    
    init {
        // Initialize Flutter dependency provider
        try {
            FlutterDependencyProvider.initialize(context)
            initialized = true
            Log.i(TAG, "Signal Protocol handler initialized")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to initialize FlutterDependencyProvider", e)
            initialized = false
        }
    }
    
    private fun getCryptographicService(): SekretessCryptographicService? {
        return if (initialized) {
            try {
                FlutterDependencyProvider.getCryptographicService()
            } catch (e: Exception) {
                Log.e(TAG, "Failed to get cryptographic service", e)
                null
            }
        } else {
            null
        }
    }
    
    fun init(): Boolean {
        try {
            Log.i(TAG, "Initializing Signal Protocol")
            val cryptoService = getCryptographicService()
            if (cryptoService != null) {
                return cryptoService.init()
            } else {
                Log.e(TAG, "Cryptographic service not available")
                return false
            }
        } catch (e: Exception) {
            Log.e(TAG, "Failed to initialize Signal Protocol", e)
            return false
        }
    }
    
    fun decryptGroupChatMessage(sender: String, base64Message: String): String? {
        try {
            Log.d(TAG, "Decrypting group chat message from $sender")
            val cryptoService = getCryptographicService()
            if (cryptoService != null) {
                val result: Optional<String> = cryptoService.decryptGroupChatMessage(sender, base64Message)
                return result.orElse(null)
            }
            return null
        } catch (e: Exception) {
            Log.e(TAG, "Failed to decrypt group chat message", e)
            return null
        }
    }
    
    fun decryptPrivateMessage(sender: String, base64Message: String): String? {
        try {
            Log.d(TAG, "Decrypting private message from $sender")
            val cryptoService = getCryptographicService()
            if (cryptoService != null) {
                val result: Optional<String> = cryptoService.decryptPrivateMessage(sender, base64Message)
                return result.orElse(null)
            }
            return null
        } catch (e: Exception) {
            Log.e(TAG, "Failed to decrypt private message", e)
            return null
        }
    }
    
    fun processKeyDistributionMessage(name: String, base64Key: String) {
        try {
            Log.d(TAG, "Processing key distribution message for $name")
            val cryptoService = getCryptographicService()
            cryptoService?.processKeyDistributionMessage(name, base64Key)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to process key distribution message", e)
        }
    }
    
    fun updateOneTimeKeys() {
        try {
            Log.d(TAG, "Updating one-time keys")
            val cryptoService = getCryptographicService()
            cryptoService?.updateOneTimeKeys()
        } catch (e: Exception) {
            Log.e(TAG, "Failed to update one-time keys", e)
        }
    }
    
    fun initializeKeyBundle(): Map<String, Any>? {
        try {
            Log.d(TAG, "Initializing key bundle")
            val cryptoService = getCryptographicService()
            if (cryptoService != null) {
                val keyBundle = cryptoService.initializeKeyBundle()
                // Convert KeyBundle to Map for Flutter
                return io.sekretess.bridge.KeyBundleConverter.toMap(keyBundle)
            }
            return null
        } catch (e: Exception) {
            Log.e(TAG, "Failed to initialize key bundle", e)
            return null
        }
    }
}

package io.sekretess.bridge;

import android.content.Context;
import android.util.Log;
import android.widget.Toast;

import org.signal.libsignal.protocol.state.KyberPreKeyRecord;
import org.signal.libsignal.protocol.state.PreKeyRecord;

import io.sekretess.dto.KeyBundle;

/**
 * Bridge for API calls from native Signal Protocol code.
 * This can be extended to call back to Flutter via MethodChannel if needed.
 */
public class NativeApiClientBridge {
    private static final String TAG = "NativeApiClientBridge";
    private final Context context;
    
    // Callback interface for API operations
    public interface ApiCallback {
        boolean onUpsertKeyStore(KeyBundle keyBundle);
        boolean onUpdateOneTimeKeys(PreKeyRecord[] preKeyRecords, KyberPreKeyRecord[] kyberPreKeyRecords);
    }
    
    private ApiCallback apiCallback;
    
    public NativeApiClientBridge(Context context) {
        this.context = context;
    }
    
    public void setApiCallback(ApiCallback callback) {
        this.apiCallback = callback;
    }
    
    public boolean upsertKeyStore(KeyBundle keyBundle) {
        if (apiCallback != null) {
            return apiCallback.onUpsertKeyStore(keyBundle);
        }
        Log.w(TAG, "ApiCallback not set, cannot upsert key store");
        return false;
    }
    
    public boolean updateOneTimeKeys(PreKeyRecord[] preKeyRecords, KyberPreKeyRecord[] kyberPreKeyRecords) {
        if (apiCallback != null) {
            return apiCallback.onUpdateOneTimeKeys(preKeyRecords, kyberPreKeyRecords);
        }
        Log.w(TAG, "ApiCallback not set, cannot update one-time keys");
        return false;
    }
    
    public Context getApplicationContext() {
        return context;
    }
    
    public void showToast(String message) {
        if (context != null) {
            Toast.makeText(context, message, Toast.LENGTH_LONG).show();
        }
    }
}

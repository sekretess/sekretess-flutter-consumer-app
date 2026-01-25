package io.sekretess.bridge;

import android.util.Log;

import org.signal.libsignal.protocol.InvalidKeyException;
import org.signal.libsignal.protocol.state.KyberPreKeyRecord;
import org.signal.libsignal.protocol.state.PreKeyRecord;

import java.util.ArrayList;
import java.util.Base64;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.sekretess.dto.KeyBundle;
import io.sekretess.utils.SerializationUtils;

/**
 * Converts native KeyBundle objects to Maps that can be sent to Flutter via MethodChannel.
 */
public class KeyBundleConverter {
    private static final String TAG = "KeyBundleConverter";
    private static final Base64.Encoder encoder = Base64.getEncoder();

    /**
     * Converts a KeyBundle to a Map that can be serialized and sent to Flutter.
     */
    public static Map<String, Object> toMap(KeyBundle keyBundle) {
        try {
            Map<String, Object> map = new HashMap<>();
            
            map.put("RegID", keyBundle.getRegistrationId());
            map.put("ik", encoder.encodeToString(
                keyBundle.getIdentityKeyPair().getPublicKey().serialize()
            ));
            map.put("spk", encoder.encodeToString(
                keyBundle.getSignedPreKeyRecord().getKeyPair().getPublicKey().serialize()
            ));
            map.put("spkID", String.valueOf(keyBundle.getSignedPreKeyRecord().getId()));
            map.put("SPKSignature", encoder.encodeToString(
                keyBundle.getSignedPreKeyRecord().getSignature()
            ));
            
            // Serialize one-time prekeys
            String[] opk = SerializationUtils.serializeSignedPreKeys(keyBundle.getOpk());
            List<String> opkList = new ArrayList<>();
            for (String s : opk) {
                opkList.add(s);
            }
            map.put("opk", opkList);
            
            // Serialize post-quantum keys
            KyberPreKeyRecord[] kyberPreKeyRecords = keyBundle.getKyberPreKeyRecords();
            KyberPreKeyRecord lastKyberPreKeyRecord = kyberPreKeyRecords[kyberPreKeyRecords.length - 1];
            
            // OPQK (all except last)
            String[] opqk = SerializationUtils.serializeKyberPreKeys(kyberPreKeyRecords);
            List<String> opqkList = new ArrayList<>();
            for (String s : opqk) {
                opqkList.add(s);
            }
            map.put("OPQK", opqkList);
            
            // PQSPK (last resort key)
            map.put("PQSPK", SerializationUtils.serializeKyberPreKey(lastKyberPreKeyRecord));
            map.put("PQSPKID", String.valueOf(lastKyberPreKeyRecord.getId()));
            map.put("PQSPKSignature", encoder.encodeToString(lastKyberPreKeyRecord.getSignature()));
            
            return map;
        } catch (InvalidKeyException e) {
            Log.e(TAG, "Failed to convert KeyBundle to Map", e);
            return new HashMap<>();
        }
    }

    /**
     * Converts PreKeyRecord and KyberPreKeyRecord arrays to a Map for one-time keys update.
     */
    public static Map<String, Object> oneTimeKeysToMap(
            PreKeyRecord[] preKeyRecords,
            KyberPreKeyRecord[] kyberPreKeyRecords) {
        try {
            Map<String, Object> map = new HashMap<>();
            
            // Serialize prekeys
            String[] opk = SerializationUtils.serializeSignedPreKeys(preKeyRecords);
            List<String> opkList = new ArrayList<>();
            for (String s : opk) {
                opkList.add(s);
            }
            map.put("OPK", opkList);
            
            // Serialize kyber prekeys (all except last)
            String[] opqk = SerializationUtils.serializeKyberPreKeys(kyberPreKeyRecords);
            List<String> opqkList = new ArrayList<>();
            for (String s : opqk) {
                opqkList.add(s);
            }
            map.put("OPQK", opqkList);
            
            return map;
        } catch (InvalidKeyException e) {
            Log.e(TAG, "Failed to convert one-time keys to Map", e);
            return new HashMap<>();
        }
    }
}

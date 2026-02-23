import Flutter
import Foundation

/// Handler for Signal Protocol operations on iOS.
/// This class bridges Flutter MethodChannel calls to the native Signal Protocol implementation.
@objc class SignalProtocolHandler: NSObject {
    private let channel: FlutterMethodChannel
    private var cryptographicService: SekretessCryptographicService?
    
    init(messenger: FlutterBinaryMessenger) {
        channel = FlutterMethodChannel(
            name: "io.sekretess/signal_protocol",
            binaryMessenger: messenger
        )
        super.init()
        
        // Initialize Flutter dependency provider
        FlutterDependencyProvider.initialize()
        cryptographicService = FlutterDependencyProvider.getCryptographicService()
        
        channel.setMethodCallHandler { [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
            self?.handleMethodCall(call: call, result: result)
        }
    }
    
    private func handleMethodCall(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let service = cryptographicService else {
            result(FlutterError(
                code: "SERVICE_NOT_AVAILABLE",
                message: "Cryptographic service not initialized",
                details: nil
            ))
            return
        }
        
        switch call.method {
        case "init":
            // CRITICAL: Execute init on a background thread to avoid blocking the MethodChannel handler
            // This allows nested MethodChannel calls (upsertKeyStore) to complete properly
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let success = try service.initialize()
                    // Post result back to main thread
                    DispatchQueue.main.async {
                        result(success)
                    }
                } catch {
                    DispatchQueue.main.async {
                        result(FlutterError(
                            code: "INIT_ERROR",
                            message: error.localizedDescription,
                            details: nil
                        ))
                    }
                }
            }
            
        case "decryptGroupChatMessage":
            guard let args = call.arguments as? [String: Any],
                  let sender = args["sender"] as? String,
                  let base64Message = args["base64Message"] as? String else {
                result(FlutterError(
                    code: "INVALID_ARGUMENTS",
                    message: "Sender and base64Message are required",
                    details: nil
                ))
                return
            }
            
            do {
                let decrypted = try service.decryptGroupChatMessage(sender: sender, base64Message: base64Message)
                result(decrypted)
            } catch {
                result(FlutterError(
                    code: "DECRYPT_ERROR",
                    message: error.localizedDescription,
                    details: nil
                ))
            }
            
        case "decryptPrivateMessage":
            guard let args = call.arguments as? [String: Any],
                  let sender = args["sender"] as? String,
                  let base64Message = args["base64Message"] as? String else {
                result(FlutterError(
                    code: "INVALID_ARGUMENTS",
                    message: "Sender and base64Message are required",
                    details: nil
                ))
                return
            }
            
            do {
                let decrypted = try service.decryptPrivateMessage(sender: sender, base64Message: base64Message)
                result(decrypted)
            } catch {
                result(FlutterError(
                    code: "DECRYPT_ERROR",
                    message: error.localizedDescription,
                    details: nil
                ))
            }
            
        case "processKeyDistributionMessage":
            guard let args = call.arguments as? [String: Any],
                  let name = args["name"] as? String,
                  let base64Key = args["base64Key"] as? String else {
                result(FlutterError(
                    code: "INVALID_ARGUMENTS",
                    message: "Name and base64Key are required",
                    details: nil
                ))
                return
            }
            
            do {
                try service.processKeyDistributionMessage(name: name, base64Key: base64Key)
                result(nil)
            } catch {
                result(FlutterError(
                    code: "PROCESS_KEY_ERROR",
                    message: error.localizedDescription,
                    details: nil
                ))
            }
            
        case "updateOneTimeKeys":
            do {
                try service.updateOneTimeKeys()
                result(nil)
            } catch {
                result(FlutterError(
                    code: "UPDATE_KEYS_ERROR",
                    message: error.localizedDescription,
                    details: nil
                ))
            }
            
        case "clearSignalKeys":
            service.clearSignalKeys()
            result(nil)
            
        case "initializeKeyBundle":
            do {
                let keyBundle = try service.initializeKeyBundle()
                let keyBundleMap = KeyBundleConverter.toMap(keyBundle: keyBundle)
                result(keyBundleMap)
            } catch {
                result(FlutterError(
                    code: "INIT_KEY_BUNDLE_ERROR",
                    message: error.localizedDescription,
                    details: nil
                ))
            }
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}

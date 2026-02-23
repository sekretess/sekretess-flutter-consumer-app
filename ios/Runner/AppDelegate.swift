import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  private var signalProtocolHandler: SignalProtocolHandler?
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    
    // Set up Signal Protocol handler
    guard let controller = window?.rootViewController as? FlutterViewController else {
      return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    signalProtocolHandler = SignalProtocolHandler(messenger: controller.binaryMessenger)
    
    // Set up API bridge channel for native-to-Flutter calls
    setupApiBridgeChannel(messenger: controller.binaryMessenger)
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  private func setupApiBridgeChannel(messenger: FlutterBinaryMessenger) {
    let apiBridgeChannel = FlutterMethodChannel(
      name: "io.sekretess/api_bridge",
      binaryMessenger: messenger
    )
    
    // Set callback for API calls from native code
    FlutterDependencyProvider.setApiCallback { method, arguments in
      // Use DispatchGroup for better synchronization
      let group = DispatchGroup()
      var resultValue = false
      let resultLock = NSLock()
      
      print("AppDelegate: Calling \(method) via MethodChannel (thread: \(Thread.current.name ?? "unknown"))")
      
      // CRITICAL: Always post to main thread to ensure MethodChannel works correctly
      // The callback will complete the DispatchGroup
      DispatchQueue.main.async {
        print("AppDelegate: Executing invokeMethod on main thread")
        apiBridgeChannel.invokeMethod(method, arguments: arguments) { result in
          print("AppDelegate: \(method) callback invoked (thread: \(Thread.current.name ?? "unknown"))")
          resultLock.lock()
          defer { resultLock.unlock() }
          
          if let error = result as? FlutterError {
            print("AppDelegate: API bridge error: \(error.message ?? "Unknown error")")
            resultValue = false
          } else {
            resultValue = result as? Bool ?? false
            print("AppDelegate: \(method) completed with result: \(resultValue)")
          }
          group.leave()
          print("AppDelegate: DispatchGroup left")
        }
      }
      
      // Enter the group before waiting
      group.enter()
      
      // Wait for result on a background thread to avoid blocking the main thread
      // This prevents deadlock since Flutter's handler also runs on the main thread
      print("AppDelegate: Waiting for \(method) response...")
      let startTime = Date()
      
      //let waitResult = group.wait(timeout: .now() + 60) // Increased timeout to 60 seconds
      //let elapsed = Date().timeIntervalSince(startTime)
      return true
//      if waitResult == .timedOut {
//        print("AppDelegate: Timeout waiting for \(method) response (elapsed: \(elapsed)s)")
//        return false
//      } else {
//        resultLock.lock()
//        defer { resultLock.unlock() }
//        print("AppDelegate: \(method) completed: \(resultValue) (elapsed: \(elapsed)s)")
//        return resultValue
//      }
    }
  }
}

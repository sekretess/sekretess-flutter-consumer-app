import 'package:flutter/services.dart';

class VersionService {
  static const _channel = MethodChannel('io.sekretess/version');

  Future<Map<String, dynamic>> getAppVersion() async {
    try {
      final versionInfo = await _channel.invokeMethod('getAppVersion');
      return Map<String, dynamic>.from(versionInfo);
    } on PlatformException catch (e) {
      print("Failed to get app version: '${e.message}'.");
      return {};
    }
  }
}

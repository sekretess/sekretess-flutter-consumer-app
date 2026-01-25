import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';

import '../../core/network/api_client.dart';
import '../models/key_bundle_dto.dart';
import '../models/one_time_key_bundle_dto.dart';

/// Service to bridge API calls from native Android Signal Protocol code to Flutter's ApiClient.
/// This handles the reverse MethodChannel where native code can request Flutter to make API calls.
@lazySingleton
class ApiBridgeService {
  static const MethodChannel _channel = MethodChannel('io.sekretess/api_bridge');
  final ApiClient _apiClient;
  final Logger _logger = Logger();
  bool _isInitialized = false;

  ApiBridgeService(this._apiClient);

  /// Initialize the API bridge service and set up the MethodChannel handler.
  /// This allows native code to call Flutter's ApiClient methods.
  Future<void> initialize() async {
    if (_isInitialized) {
      _logger.i('ApiBridgeService already initialized');
      return;
    }

    _logger.i('ApiBridgeService: Setting up MethodChannel handler');
    _channel.setMethodCallHandler((call) async {
      // #region agent log
      try { final logFile = File('/Users/elnur/StudioProjects/consumer-android-app/.cursor/debug.log'); await logFile.writeAsString('${jsonEncode({"location":"api_bridge_service.dart:30","message":"Handler entry","data":{"method":call.method},"timestamp":DateTime.now().millisecondsSinceEpoch,"sessionId":"debug-session","runId":"run1","hypothesisId":"A,B,C,D,E"})}\n', mode: FileMode.append); } catch (_) {}
      // #endregion
      print('ApiBridgeService: MethodChannel handler invoked for: ${call.method}');
      _logger.i('ApiBridgeService: MethodChannel handler invoked for: ${call.method}');
      try {
        final result = await _handleMethodCall(call);
        // #region agent log
        try { final logFile = File('/Users/elnur/StudioProjects/consumer-android-app/.cursor/debug.log'); await logFile.writeAsString('${jsonEncode({"location":"api_bridge_service.dart:35","message":"Handler result ready","data":{"method":call.method,"result":result,"resultType":result.runtimeType.toString()},"timestamp":DateTime.now().millisecondsSinceEpoch,"sessionId":"debug-session","runId":"run1","hypothesisId":"A,B"})}\n', mode: FileMode.append); } catch (_) {}
        // #endregion
        print('ApiBridgeService: Method call ${call.method} completed successfully with result: $result');
        _logger.i('ApiBridgeService: Method call ${call.method} completed successfully with result: $result');
        // Explicitly return the result
        // #region agent log
        try { final logFile = File('/Users/elnur/StudioProjects/consumer-android-app/.cursor/debug.log'); await logFile.writeAsString('${jsonEncode({"location":"api_bridge_service.dart:39","message":"About to return","data":{"method":call.method,"result":result},"timestamp":DateTime.now().millisecondsSinceEpoch,"sessionId":"debug-session","runId":"run1","hypothesisId":"B"})}\n', mode: FileMode.append); } catch (_) {}
        // #endregion
        return result;
      } catch (e, stackTrace) {
        // #region agent log
        try { final logFile = File('/Users/elnur/StudioProjects/consumer-android-app/.cursor/debug.log'); await logFile.writeAsString('${jsonEncode({"location":"api_bridge_service.dart:41","message":"Handler exception","data":{"method":call.method,"error":e.toString()},"timestamp":DateTime.now().millisecondsSinceEpoch,"sessionId":"debug-session","runId":"run1","hypothesisId":"D"})}\n', mode: FileMode.append); } catch (_) {}
        // #endregion
        print('ApiBridgeService: Exception in handler for ${call.method}: $e');
        _logger.e('ApiBridgeService: Exception in handler for ${call.method}', error: e, stackTrace: stackTrace);
        // Re-throw to let Flutter handle it as a PlatformException
        rethrow;
      }
    });
    _isInitialized = true;
    _logger.i('ApiBridgeService initialized and handler registered');
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    _logger.i('ApiBridgeService: Received method call: ${call.method}');
    try {
      switch (call.method) {
        case 'upsertKeyStore':
          _logger.i('ApiBridgeService: Processing upsertKeyStore');
          final keyBundleMap = call.arguments as Map<dynamic, dynamic>;
          final success = await _handleUpsertKeyStore(keyBundleMap);
          _logger.i('ApiBridgeService: upsertKeyStore completed with result: $success');
          return success;
        case 'updateOneTimeKeys':
          _logger.i('ApiBridgeService: Processing updateOneTimeKeys');
          final keysMap = call.arguments as Map<dynamic, dynamic>;
          final success = await _handleUpdateOneTimeKeys(keysMap);
          _logger.i('ApiBridgeService: updateOneTimeKeys completed with result: $success');
          return success;
        default:
          _logger.w('ApiBridgeService: Unknown method: ${call.method}');
          throw PlatformException(
            code: 'NOT_IMPLEMENTED',
            message: 'Method ${call.method} is not implemented',
          );
      }
    } catch (e, stackTrace) {
      _logger.e('ApiBridgeService: Error handling method call: ${call.method}', error: e, stackTrace: stackTrace);
      if (e is PlatformException) {
        rethrow;
      }
      throw PlatformException(
        code: 'METHOD_CALL_ERROR',
        message: 'Error handling ${call.method}: ${e.toString()}',
        details: e.toString(),
      );
    }
  }

  Future<bool> _handleUpsertKeyStore(Map<dynamic, dynamic> keyBundleMap) async {
    _logger.i('ApiBridgeService: _handleUpsertKeyStore started');
    try {
      // Convert map to KeyBundleDto
      _logger.i('ApiBridgeService: Converting keyBundleMap to KeyBundleDto');
      final keyBundleDto = KeyBundleDto.fromJson(
        Map<String, dynamic>.from(keyBundleMap),
      );
      _logger.i('ApiBridgeService: KeyBundleDto created successfully');

      // Get Firebase messaging token
      String? token;
      try {
        _logger.i('ApiBridgeService: Getting Firebase messaging token');
        token = await FirebaseMessaging.instance.getToken();
        _logger.i('ApiBridgeService: Firebase token obtained: ${token?.substring(0, 20)}...');
      } catch (e) {
        _logger.e('ApiBridgeService: Failed to get Firebase token', error: e);
        // Continue without token
      }

      final keyBundleToSend = token != null
          ? KeyBundleDto(
              regId: keyBundleDto.regId,
              ik: keyBundleDto.ik,
              spk: keyBundleDto.spk,
              opk: keyBundleDto.opk,
              spkSignature: keyBundleDto.spkSignature,
              spkId: keyBundleDto.spkId,
              pqspk: keyBundleDto.pqspk,
              pqspkId: keyBundleDto.pqspkId,
              pqspkSignature: keyBundleDto.pqspkSignature,
              opqk: keyBundleDto.opqk,
              deviceRegistrationToken: token,
            )
          : keyBundleDto;

      _logger.i('ApiBridgeService: Calling ApiClient.upsertKeyStore');
      print('ApiBridgeService: Calling ApiClient.upsertKeyStore');
      // #region agent log
      try { final logFile = File('/Users/elnur/StudioProjects/consumer-android-app/.cursor/debug.log'); await logFile.writeAsString('${jsonEncode({"location":"api_bridge_service.dart:123","message":"Before HTTP call","data":{},"timestamp":DateTime.now().millisecondsSinceEpoch,"sessionId":"debug-session","runId":"run1","hypothesisId":"A"})}\n', mode: FileMode.append); } catch (_) {}
      // #endregion
      final success = await _apiClient.upsertKeyStore(keyBundleToSend.toJson());
      // #region agent log
      try { final logFile = File('/Users/elnur/StudioProjects/consumer-android-app/.cursor/debug.log'); await logFile.writeAsString('${jsonEncode({"location":"api_bridge_service.dart:126","message":"After HTTP call","data":{"success":success,"successType":success.runtimeType.toString()},"timestamp":DateTime.now().millisecondsSinceEpoch,"sessionId":"debug-session","runId":"run1","hypothesisId":"A,B"})}\n', mode: FileMode.append); } catch (_) {}
      // #endregion
      print('ApiBridgeService: ApiClient.upsertKeyStore returned: $success (type: ${success.runtimeType})');
      _logger.i('ApiBridgeService: ApiClient.upsertKeyStore returned: $success');
      // Ensure we return a boolean, not null
      final boolResult = success == true;
      // #region agent log
      try { final logFile = File('/Users/elnur/StudioProjects/consumer-android-app/.cursor/debug.log'); await logFile.writeAsString('${jsonEncode({"location":"api_bridge_service.dart:131","message":"Before return","data":{"boolResult":boolResult},"timestamp":DateTime.now().millisecondsSinceEpoch,"sessionId":"debug-session","runId":"run1","hypothesisId":"B"})}\n', mode: FileMode.append); } catch (_) {}
      // #endregion
      print('ApiBridgeService: Returning bool result: $boolResult');
      return boolResult;
    } catch (e, stackTrace) {
      _logger.e('ApiBridgeService: Failed to upsert key store', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  Future<bool> _handleUpdateOneTimeKeys(Map<dynamic, dynamic> keysMap) async {
    try {
      // Convert map to OneTimeKeyBundleDto
      final oneTimeKeys = OneTimeKeyBundleDto.fromJson(
        Map<String, dynamic>.from(keysMap),
      );

      final success = await _apiClient.updateOneTimeKeys(oneTimeKeys.toJson());
      _logger.i('Update one-time keys result: $success');
      return success;
    } catch (e) {
      _logger.e('Failed to update one-time keys', error: e);
      return false;
    }
  }
}

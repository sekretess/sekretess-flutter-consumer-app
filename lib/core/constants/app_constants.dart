class AppConstants {
  // API URLs - These should be set via build configuration
  static const String authApiUrl = String.fromEnvironment(
    'AUTH_API_URL',
    defaultValue: 'https://auth.test.sekretess.io/realms/consumer/.well-known/openid-configuration',
  );

  static const String consumerApiUrl = String.fromEnvironment(
    'CONSUMER_API_URL',
    defaultValue: 'https://consumer.test.sekretess.io/api/v1/consumers',
  );

  static const String businessApiUrl = String.fromEnvironment(
    'BUSINESS_API_URL',
    defaultValue: 'https://business.test.sekretess.net/api/v1/businesses',
  );

  static const String webSocketUrl = String.fromEnvironment(
    'WEB_SOCKET_URL',
    defaultValue: 'wss://consumer.test.sekretess.io/api/v1/consumers',
  );

  // App Constants
  static const String appName = 'Sekretess';
  static const String notificationChannelName = 'sekretess_notif';
  static const String usernameClaim = 'preferred_username';
  static const String eventNewIncomingMessage = 'new-incoming-message-event';
  
  // Signal Protocol
  static const int signalKeyCount = 15;
  static const int deviceId = 1;
  
  // WebSocket
  static const int messageHandlingSuccess = 2;
  static const int messageHandlingFailed = 3;
  
  // Network
  static const int connectionTimeout = 20; // seconds
  static const int receiveTimeout = 20; // seconds
}

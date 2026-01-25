import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/di/injection.dart';
import '../../core/network/websocket_service.dart';
import '../../core/enums/sekretess_event.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/services/cryptographic_service.dart';
import '../../data/services/message_service.dart';
import '../../core/theme/app_colors.dart';
import 'home_page.dart';
import 'businesses_page.dart';
import 'login_page.dart';
import 'profile_page.dart';

class MainPage extends ConsumerStatefulWidget {
  const MainPage({super.key});

  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {
  int _currentIndex = 0;
  late final WebSocketService _webSocketService;
  late final AuthRepository _authRepository;
  late final CryptographicService _cryptographicService;
  StreamSubscription<SekretessEvent>? _eventSubscription;
  StreamSubscription<bool>? _logoutSubscription;
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? _snackBarController;

  final List<Widget> _pages = [
    const HomePage(),
    const BusinessesPage(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _webSocketService = getIt<WebSocketService>();
    _authRepository = getIt<AuthRepository>();
    _cryptographicService = getIt<CryptographicService>();
    // Delay Signal Protocol initialization to ensure ApiBridgeService handler is registered
    Future.delayed(const Duration(milliseconds: 500), () {
      _initializeSignalProtocol();
    });
    _connectWebSocket();
    _listenToWebSocketEvents();
    _listenToLogoutEvents();
    // TEMPORARY: Insert test messages at startup - REMOVE IN PRODUCTION
    // _insertTestData();
  }

  Future<void> _initializeSignalProtocol() async {
    try {
      final success = await _cryptographicService.init();
      if (!success) {
        // Handle initialization failure
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to initialize encryption. Please restart the app.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Handle error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error initializing encryption: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _connectWebSocket() async {
    try {
      await _webSocketService.connect();
    } catch (e) {
      // Connection will be handled by event stream
    }
  }

  void _listenToWebSocketEvents() {
    _eventSubscription = _webSocketService.eventStream.listen((event) {
      if (mounted) {
        switch (event) {
          case SekretessEvent.websocketConnectionEstablished:
            _hideConnectionSnackbar();
            break;
          case SekretessEvent.websocketConnectionLost:
            _showConnectionSnackbar();
            break;
          case SekretessEvent.authFailed:
            _webSocketService.disconnect();
            _navigateToLogin();
            break;
        }
      }
    });
  }

  void _listenToLogoutEvents() {
    _logoutSubscription = _authRepository.logoutStream.listen((_) {
      if (mounted) {
        _webSocketService.disconnect();
        _navigateToLogin();
      }
    });
  }

  void _navigateToLogin() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false, // Remove all previous routes
    );
  }

  void _showConnectionSnackbar() {
    if (_snackBarController != null) return;

    _snackBarController = ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.wifi_off, color: Colors.white),
            SizedBox(width: 12),
            Expanded(
              child: Text('Network lost...'),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        duration: const Duration(days: 1), // Show indefinitely until dismissed
        action: SnackBarAction(
          label: 'Reconnect',
          textColor: Colors.white,
          onPressed: () {
            // Close the current snackbar so it can reappear if connection fails
            _hideConnectionSnackbar();
            _webSocketService.connect();
          },
        ),
      ),
    );
    
    // Reset controller when snackbar is dismissed (e.g., by user swipe)
    _snackBarController?.closed.then((_) {
      _snackBarController = null;
    });
  }

  void _hideConnectionSnackbar() {
    _snackBarController?.close();
    _snackBarController = null;
  }

  // TEMPORARY: Insert test messages at startup - REMOVE IN PRODUCTION
  Future<void> _insertTestData() async {
    try {
      // Wait a bit to ensure user is authenticated
      await Future.delayed(const Duration(seconds: 1));
      final messageService = getIt<MessageService>();
      await messageService.insertTestData();
    } catch (e) {
      // Silently fail - this is just for testing
      print('Failed to insert test data: $e');
    }
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    _logoutSubscription?.cancel();
    _hideConnectionSnackbar();
    super.dispose();
  }

  String _getAppBarTitle() {
    switch (_currentIndex) {
      case 0:
        return 'Home';
      case 1:
        return 'Businesses';
      case 2:
        return 'Profile';
      default:
        return 'Sekretess';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        title: Text(_getAppBarTitle()),
        elevation: 0,
        backgroundColor: AppColors.primaryBackground,
        foregroundColor: AppColors.white,
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: AppColors.primaryBackground,
        selectedItemColor: AppColors.sekretessBlue,
        unselectedItemColor: AppColors.textTertiary,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.business),
            label: 'Businesses',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:golds_nuts/core/services/firebase_messaging_service.dart';

class NotificationHandler {
  final FirebaseMessagingService messagingService;

  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<RemoteMessage>? _openedAppSubscription;

  bool _isInitialized = false;

  NotificationHandler({
    required this.messagingService,
  });

  Future<void> initialize({
    required Future<void> Function(RemoteMessage message)
    onForegroundMessage,
    required Future<void> Function(RemoteMessage message)
    onNotificationTap,
  }) async {
    // Prevent registering listeners more than once.
    if (_isInitialized) return;

    _isInitialized = true;

    // 1. App is in foreground.
    _foregroundSubscription =
        messagingService.onMessage.listen(
              (message) {
            unawaited(
              _handleMessage(
                message,
                onForegroundMessage,
              ),
            );
          },
        );

    // 2. App is in background and user taps notification.
    _openedAppSubscription =
        messagingService.onMessageOpenedApp.listen(
              (message) {
            unawaited(
              _handleMessage(
                message,
                onNotificationTap,
              ),
            );
          },
        );

    // 3. App was terminated and opened by notification tap.
    try {
      final initialMessage =
      await messagingService.getInitialMessage();

      if (initialMessage != null) {
        await _handleMessage(
          initialMessage,
          onNotificationTap,
        );
      }
    } catch (e) {
      // Notification handling errors should not crash the app.
    }
  }

  Future<void> _handleMessage(
      RemoteMessage message,
      Future<void> Function(RemoteMessage message) callback,
      ) async {
    try {
      await callback(message);
    } catch (e) {
      // Handle callback errors without crashing the app.
    }
  }

  Future<void> dispose() async {
    await _foregroundSubscription?.cancel();
    await _openedAppSubscription?.cancel();

    _foregroundSubscription = null;
    _openedAppSubscription = null;

    _isInitialized = false;
  }
}
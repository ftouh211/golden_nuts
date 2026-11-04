import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationPermissionService {
  final FirebaseMessaging firebaseMessaging;

  NotificationPermissionService({
    required this.firebaseMessaging,
  });

  // Request notification permission
  Future<NotificationSettings> requestPermission() async {
    return await firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  // Check if user granted notification permission
  Future<bool> hasNotificationPermission() async {
    final settings =
    await firebaseMessaging.getNotificationSettings();

    return settings.authorizationStatus ==
        AuthorizationStatus.authorized ||
        settings.authorizationStatus ==
            AuthorizationStatus.provisional;
  }

  // Get current FCM token
  Future<String?> getToken() async {
    return await firebaseMessaging.getToken();
  }

  // Listen to token changes
  Stream<String> get onTokenRefresh {
    return firebaseMessaging.onTokenRefresh;
  }

  // Get current permission status
  Future<NotificationSettings> getPermissionStatus() async {
    return await firebaseMessaging.getNotificationSettings();
  }
}
import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseMessagingService {
  final FirebaseMessaging firebaseMessaging;

  FirebaseMessagingService({
    required this.firebaseMessaging,
  });

  // Notifications received while app is in foreground.
  Stream<RemoteMessage> get onMessage {
    return FirebaseMessaging.onMessage;
  }

  // User tapped a notification while app was in background.
  Stream<RemoteMessage> get onMessageOpenedApp {
    return FirebaseMessaging.onMessageOpenedApp;
  }

  // User opened the app by tapping a notification
  // while the app was terminated.
  Future<RemoteMessage?> getInitialMessage() async {
    return await firebaseMessaging.getInitialMessage();
  }
}
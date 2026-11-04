// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
//
// import 'package:golds_nuts/config/routes_manager/routes.dart';
// import 'package:golds_nuts/config/routes_manager/route_generator.dart';
// import 'package:golds_nuts/core/service_locator.dart';
// import 'package:golds_nuts/core/utils/app_theme.dart';
//
// import 'firebase_options.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//
//   setupDependencies();
//
//   runApp(const GoldsNutsApp());
// }
//
// class GoldsNutsApp extends StatelessWidget {
//   const GoldsNutsApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'GoldsNuts',
//       theme: AppTheme.lightTheme,
//
//       initialRoute: Routes.signInRoute,
//       onGenerateRoute: RouteGenerator.getRoute,
//     );
//   }
// }



import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'package:golds_nuts/config/routes_manager/routes.dart';
import 'package:golds_nuts/config/routes_manager/route_generator.dart';
import 'package:golds_nuts/core/service_locator.dart';
import 'package:golds_nuts/core/services/fcm_token_manager.dart';
import 'package:golds_nuts/core/services/firebase_messaging_background_handler.dart';
import 'package:golds_nuts/core/services/firebase_messaging_service.dart';
import 'package:golds_nuts/core/services/notification_handler.dart';
import 'package:golds_nuts/core/services/notification_permission_service.dart';
import 'package:golds_nuts/core/utils/app_theme.dart';
import 'package:golds_nuts/features/notifications/domain/usecases/delete_fcm_token_use_case.dart';
import 'package:golds_nuts/features/notifications/domain/usecases/save_fcm_token_use_case.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(
    firebaseMessagingBackgroundHandler,
  );
  // Firebase Authentication Emulator
  await FirebaseAuth.instance.useAuthEmulator(
    '10.0.2.2',
    9099,
  );

  // Cloud Firestore Emulator
  FirebaseFirestore.instance.useFirestoreEmulator(
    '10.0.2.2',
    8080,
  );

  // Cloud Functions Emulator
  FirebaseFunctions.instanceFor(
    region: 'us-central1',
  ).useFunctionsEmulator(
    '10.0.2.2',
    5001,
  );

  setupDependencies();

  assert(sl.isRegistered<NotificationPermissionService>());
  assert(sl.isRegistered<SaveFcmTokenUseCase>());
  assert(sl.isRegistered<DeleteFcmTokenUseCase>());
  assert(sl.isRegistered<FcmTokenManager>());
  assert(sl.isRegistered<FirebaseMessagingService>());
  assert(sl.isRegistered<NotificationHandler>());

  runApp(const GoldsNutsApp());
}

class GoldsNutsApp extends StatefulWidget {
  const GoldsNutsApp({super.key});

  @override
  State<GoldsNutsApp> createState() => _GoldsNutsAppState();
}

class _GoldsNutsAppState extends State<GoldsNutsApp> {
  late final NotificationHandler _notificationHandler;

  @override
  void initState() {
    super.initState();

    _notificationHandler = sl<NotificationHandler>();

    // Initialize notification listeners once for the whole app.
    unawaited(_initializeNotifications());
  }

  Future<void> _initializeNotifications() async {
    await _notificationHandler.initialize(
      onForegroundMessage: _onForegroundMessage,
      onNotificationTap: _onNotificationTap,
    );
  }

  // App is currently open.
  Future<void> _onForegroundMessage(RemoteMessage message) async {
    debugPrint('Foreground notification received');
    debugPrint('Title: ${message.notification?.title}');
    debugPrint('Body: ${message.notification?.body}');
    debugPrint('Data: ${message.data}');
  }

  // User tapped a notification.
  Future<void> _onNotificationTap(RemoteMessage message) async {
    debugPrint('Notification tapped');
    debugPrint('Data: ${message.data}');

    // Navigation will be implemented later.
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GoldsNuts',
      theme: AppTheme.lightTheme,
      initialRoute: Routes.signInRoute,
      onGenerateRoute: RouteGenerator.getRoute,
    );
  }

  @override
  void dispose() {
    unawaited(_notificationHandler.dispose());
    super.dispose();
  }
}
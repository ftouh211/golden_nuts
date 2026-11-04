
import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:golds_nuts/core/services/notification_permission_service.dart';
import 'package:golds_nuts/core/utils/device_info.dart';
import 'package:golds_nuts/features/notifications/domain/usecases/save_fcm_token_use_case.dart';
import 'package:golds_nuts/features/notifications/domain/usecases/delete_fcm_token_use_case.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FcmTokenManager {
  final NotificationPermissionService permissionService;
  final SaveFcmTokenUseCase saveFcmTokenUseCase;
  final DeleteFcmTokenUseCase deleteFcmTokenUseCase;

  StreamSubscription<String>? _tokenSubscription;

  String? _currentUid;

  FcmTokenManager({
    required this.permissionService,
    required this.saveFcmTokenUseCase,
    required this.deleteFcmTokenUseCase,
  });

  // Request permission only when we intentionally want to ask the user.
  Future<bool> requestPermissionAndRegister({
    required String uid,
  }) async {
    try {
      final settings = await permissionService.requestPermission();

      final isAllowed =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
              settings.authorizationStatus == AuthorizationStatus.provisional;

      if (!isAllowed) {
        await setNotificationsEnabled(false);
        return false;
      }

      await setNotificationsEnabled(true);
      await registerDevice(uid: uid);

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> registerDevice({required String uid}) async {
    try {
      final isEnabled = await areNotificationsEnabled();

      if (!isEnabled) return;

      final settings = await permissionService.getPermissionStatus();

      final isAllowed =
          settings.authorizationStatus == AuthorizationStatus.authorized ||
              settings.authorizationStatus == AuthorizationStatus.provisional;

      if (!isAllowed) return;

      _currentUid = uid;

      final token = await permissionService.getToken();

      if (token == null) return;

      await _saveToken(uid: uid, token: token);

      await _tokenSubscription?.cancel();

      _tokenSubscription = permissionService.onTokenRefresh.listen((newToken) {
        final currentUid = _currentUid;

        if (currentUid != null) {
          _saveToken(uid: currentUid, token: newToken);
        }
      });
    } catch (e) {
      // Notification registration should not block the app.
    }
  }

  Future<void> _saveToken({
    required String uid,
    required String token,
  }) async {
    try {
      await saveFcmTokenUseCase(
        uid: uid,
        token: token,
        platform: DeviceInfo.platform,
      );
    } catch (e) {
      // Ignore token registration errors.
    }
  }

  Future<void> unregisterDevice({required String uid}) async {
    try {
      await setNotificationsEnabled(false);

      await _tokenSubscription?.cancel();
      _tokenSubscription = null;

      final token = await permissionService.getToken();

      if (token != null) {
        await deleteFcmTokenUseCase(
          uid: uid,
          token: token,
        );
      }

      _currentUid = null;
    } catch (e) {
      _currentUid = null;
    }
  }

  Future<void> dispose() async {
    await _tokenSubscription?.cancel();
    _tokenSubscription = null;
    _currentUid = null;
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', enabled);
  }

  Future<bool> areNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notifications_enabled') ?? false;
  }
}

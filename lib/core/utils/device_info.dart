import 'package:flutter/foundation.dart';

class DeviceInfo {
  static String get platform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'android';

      case TargetPlatform.iOS:
        return 'ios';

      case TargetPlatform.windows:
        return 'windows';

      case TargetPlatform.macOS:
        return 'macos';

      case TargetPlatform.linux:
        return 'linux';

      case TargetPlatform.fuchsia:
        return 'fuchsia';
    }
  }
}
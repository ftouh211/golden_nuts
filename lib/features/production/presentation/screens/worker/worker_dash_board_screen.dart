
import 'package:flutter/material.dart';
import 'package:golds_nuts/core/service_locator.dart';
import 'package:golds_nuts/core/services/fcm_token_manager.dart';
import 'package:golds_nuts/core/utils/color_manager.dart';
import 'package:golds_nuts/features/auth/domain/entities/user_entity.dart';
import 'package:golds_nuts/features/production/presentation/screens/worker/worker_production_history.dart';
import 'package:golds_nuts/features/production/presentation/screens/worker/worker_production.dart';
import 'package:golds_nuts/features/production/presentation/screens/worker/worker_setting.dart';

class WorkerDashboardScreen extends StatefulWidget {
  final UserEntity user;

  const WorkerDashboardScreen({
    super.key,
    required this.user,
  });

  @override
  State<WorkerDashboardScreen> createState() =>
      _WorkerDashboardScreenState();
}

class _WorkerDashboardScreenState extends State<WorkerDashboardScreen>
    with WidgetsBindingObserver {
  int _currentIndex = 0;

  late final FcmTokenManager _fcmTokenManager;

  @override
  void initState() {
    super.initState();

    // Register lifecycle observer.
    WidgetsBinding.instance.addObserver(this);

    _fcmTokenManager = sl<FcmTokenManager>();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      _checkNotificationPermission();
    }
  }

  // Check notification permission when app returns to foreground.
  Future<void> _checkNotificationPermission() async {
    await _fcmTokenManager.registerDevice(
      uid: widget.user.uid,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      WorkerProduction(user: widget.user),
      WorkerProductionHistory(user: widget.user),
      WorkerSetting(user: widget.user),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: ColorManager.surface,
        selectedItemColor: ColorManager.primary,
        unselectedItemColor: ColorManager.textSecondary,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            activeIcon: Icon(Icons.inventory_2),
            label: 'Production',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

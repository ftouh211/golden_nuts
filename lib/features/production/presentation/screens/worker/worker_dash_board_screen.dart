
import 'package:flutter/material.dart';
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

class _WorkerDashboardScreenState
    extends State<WorkerDashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      WorkerProduction(user: widget.user),
      WorkerProductionHistory(user : widget.user),
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

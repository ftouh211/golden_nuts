
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:golds_nuts/core/service_locator.dart';
import 'package:golds_nuts/core/services/fcm_token_manager.dart';
import 'package:golds_nuts/core/utils/color_manager.dart';
import 'package:golds_nuts/features/auth/domain/entities/user_entity.dart';
import 'package:golds_nuts/features/auth/presentation/bloc/logout/logout_bloc.dart';
import 'package:golds_nuts/features/dashboard/presentation/screens/manager_dashboard_home.dart';
import 'package:golds_nuts/features/inventory/presentation/bloc/inventory_bloc.dart';
import 'package:golds_nuts/features/inventory/presentation/bloc/inventory_event.dart';
import 'package:golds_nuts/features/outgoing/presenation/bloc/outgoing_bloc.dart';
import 'package:golds_nuts/features/outgoing/presenation/bloc/outgoing_event.dart';
import 'package:golds_nuts/features/outgoing/presenation/screens/outgoing_screen.dart';
import 'package:golds_nuts/features/product/presentation/bloc/worker/get_worker/get_workers_bloc.dart';
import 'package:golds_nuts/features/product/presentation/bloc/worker/get_worker/get_workers_event.dart';
import 'package:golds_nuts/features/product/presentation/screens/create_worker/create_worker.dart';
import 'package:golds_nuts/features/product/presentation/screens/manager_screen.dart';
import 'package:golds_nuts/features/production/presentation/bloc/production/get_monthly_productions/get_monthly_productions_bloc.dart';
import 'package:golds_nuts/features/production/presentation/bloc/production/get_monthly_productions/get_monthly_productions_event.dart';
import 'package:golds_nuts/features/settings/presentation/screens/settings_screen.dart';

class ManagerDashboardScreen extends StatefulWidget {
  final UserEntity user;

  const ManagerDashboardScreen({
    super.key,
    required this.user,
  });

  @override
  State<ManagerDashboardScreen> createState() =>
      _ManagerDashboardScreenState();
}

class _ManagerDashboardScreenState extends State<ManagerDashboardScreen>
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

  // Check permission when app returns to foreground.
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

  // Refresh all dashboard data.
  void _refreshDashboard(BuildContext context) {
    context.read<GetWorkersBloc>().add(
      const GetWorkersRequested(),
    );

    context.read<InventoryBloc>().add(
      GetInventoryEvent(),
    );

    context.read<OutgoingBloc>().add(
      GetOutgoingRecordsEvent(),
    );

    context.read<GetMonthlyProductionsBloc>().add(
      GetMonthlyProductionsRequested(
        month: DateTime.now(),
      ),
    );
  }

  // Navigate between manager pages.
  void _onNavigate(BuildContext context, int index) {
    setState(() {
      _currentIndex = index;
    });

    // Refresh whenever the manager returns to Home.
    if (index == 0) {
      _refreshDashboard(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<GetMonthlyProductionsBloc>()
            ..add(
              GetMonthlyProductionsRequested(
                month: DateTime.now(),
              ),
            ),
        ),
        BlocProvider(
          create: (_) => sl<GetWorkersBloc>()
            ..add(
              const GetWorkersRequested(),
            ),
        ),
        BlocProvider(
          create: (_) => sl<InventoryBloc>()
            ..add(GetInventoryEvent()),
        ),
        BlocProvider(
          create: (_) => sl<OutgoingBloc>()
            ..add(GetOutgoingRecordsEvent()),
        ),

        // Logout Bloc
        BlocProvider(
          create: (_) => sl<LogoutBloc>(),
        ),
      ],
      child: Builder(
        builder: (providerContext) {
          return Scaffold(
            body: IndexedStack(
              index: _currentIndex,
              children: [
                ManagerDashboardHome(
                  user: widget.user,
                  onNavigate: (index) {
                    _onNavigate(providerContext, index);
                  },
                ),
                const ManagerScreen(),
                const CreateWorker(),
                const OutgoingScreen(),

                SettingsScreen(
                  user: widget.user,
                  onBack: () {
                    _onNavigate(providerContext, 0);
                  },
                ),
              ],
            ),
            bottomNavigationBar: _currentIndex == 4
                ? null
                : BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                _onNavigate(providerContext, index);
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
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.inventory_2_outlined),
                  activeIcon: Icon(Icons.inventory_2),
                  label: 'Products',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.people_outline),
                  activeIcon: Icon(Icons.people),
                  label: 'Workers',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.local_shipping_outlined),
                  activeIcon: Icon(Icons.local_shipping),
                  label: 'Outgoing',
                ),
              ],
            ),          );
        },
      ),
    );
  }
}

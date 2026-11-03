import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:golds_nuts/core/service_locator.dart';
import 'package:golds_nuts/core/utils/color_manager.dart';
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

class ManagerDashboardScreen extends StatefulWidget {
  const ManagerDashboardScreen({super.key});

  @override
  State<ManagerDashboardScreen> createState() =>
      _ManagerDashboardScreenState();
}

class _ManagerDashboardScreenState extends State<ManagerDashboardScreen> {
  int _currentIndex = 0;

  // Refresh all dashboard data
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

  // Navigate between manager pages
  void _onNavigate(BuildContext context, int index) {
    setState(() {
      _currentIndex = index;
    });

    // Refresh whenever the manager returns to Home
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
            ..add(
              GetInventoryEvent(),
            ),
        ),
        BlocProvider(
          create: (_) => sl<OutgoingBloc>()
            ..add(
              GetOutgoingRecordsEvent(),
            ),
        ),
      ],
      child: Builder(
        builder: (providerContext) {
          return Scaffold(
            body: IndexedStack(
              index: _currentIndex,
              children: [
                ManagerDashboardHome(
                  managerName: 'test',
                  onNavigate: (index) {
                    _onNavigate(providerContext, index);
                  },
                ),
                const ManagerScreen(),
                const CreateWorker(),
                const OutgoingScreen(),
              ],
            ),

            bottomNavigationBar: BottomNavigationBar(
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
            ),
          );
        },
      ),
    );
  }
}
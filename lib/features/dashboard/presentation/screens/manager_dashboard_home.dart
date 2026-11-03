import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:golds_nuts/core/utils/color_manager.dart';
import 'package:golds_nuts/features/dashboard/presentation/screens/widgets/dashboard_header.dart';
import 'package:golds_nuts/features/dashboard/presentation/screens/widgets/dashboard_quick_actions.dart';
import 'package:golds_nuts/features/dashboard/presentation/screens/widgets/dashboard_stat_card.dart';
import 'package:golds_nuts/features/dashboard/presentation/screens/widgets/production_chart.dart';
import 'package:golds_nuts/features/inventory/presentation/bloc/inventory_bloc.dart';
import 'package:golds_nuts/features/inventory/presentation/bloc/inventory_event.dart';
import 'package:golds_nuts/features/inventory/presentation/bloc/inventory_state.dart';
import 'package:golds_nuts/features/outgoing/presenation/bloc/outgoing_bloc.dart';
import 'package:golds_nuts/features/outgoing/presenation/bloc/outgoing_event.dart';
import 'package:golds_nuts/features/outgoing/presenation/bloc/outgoing_state.dart';
import 'package:golds_nuts/features/product/presentation/bloc/worker/get_worker/get_workers_bloc.dart';
import 'package:golds_nuts/features/product/presentation/bloc/worker/get_worker/get_workers_event.dart';
import 'package:golds_nuts/features/product/presentation/bloc/worker/get_worker/get_workers_state.dart';
import 'package:golds_nuts/features/production/presentation/bloc/production/get_monthly_productions/get_monthly_productions_bloc.dart';
import 'package:golds_nuts/features/production/presentation/bloc/production/get_monthly_productions/get_monthly_productions_event.dart';
import 'package:golds_nuts/features/production/presentation/bloc/production/get_monthly_productions/get_monthly_productions_state.dart';

class ManagerDashboardHome extends StatefulWidget {
  final String managerName;
  final ValueChanged<int> onNavigate;

  const ManagerDashboardHome({
    super.key,
    required this.managerName,
    required this.onNavigate,
  });

  @override
  State<ManagerDashboardHome> createState() => _ManagerDashboardHomeState();
}

class _ManagerDashboardHomeState extends State<ManagerDashboardHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.background,
      body: Column(
        children: [
          DashboardHeader(managerName: widget.managerName),

          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Factory Overview',
                      style: TextStyle(
                        color: ColorManager.textPrimary,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    _buildStatistics(),

                    const SizedBox(height: 20),

                    const Text(
                      'Production Analytics',
                      style: TextStyle(
                        color: ColorManager.textPrimary,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    _buildProductionChart(),

                    const SizedBox(height: 18),

                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        color: ColorManager.textPrimary,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 12),

                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.35,
                      children: [
                        QuickActionCard(
                          title: 'Add Worker',
                          subtitle: 'Create worker account',
                          icon: Icons.person_add_alt_1_rounded,
                          onTap: () => widget.onNavigate(2),
                        ),
                        QuickActionCard(
                          title: 'Products',
                          subtitle: 'Manage factory products',
                          icon: Icons.inventory_2_rounded,
                          onTap: () => widget.onNavigate(1),
                        ),
                        QuickActionCard(
                          title: 'Production',
                          subtitle: 'View production records',
                          icon: Icons.factory_rounded,
                          onTap: () {
                            // هنربطها بشاشة الإنتاج لما نحدد مكانها.
                          },
                        ),
                        QuickActionCard(
                          title: 'New Outgoing',
                          subtitle: 'Register outgoing stock',
                          icon: Icons.local_shipping_rounded,
                          onTap: () => widget.onNavigate(3),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics() {
    return BlocBuilder<GetWorkersBloc, GetWorkersState>(
      builder: (context, workersState) {
        return BlocBuilder<InventoryBloc, InventoryState>(
          builder: (context, inventoryState) {
            return BlocBuilder<OutgoingBloc, OutgoingState>(
              builder: (context, outgoingState) {
                return BlocBuilder<
                  GetMonthlyProductionsBloc,
                  GetMonthlyProductionsState
                >(
                  builder: (context, productionState) {
                    final workersLoading = workersState is GetWorkersLoading;
                    final inventoryLoading = inventoryState is InventoryLoading;
                    final outgoingLoading =
                        outgoingState is OutgoingRecordsLoading;
                    final productionLoading =
                        productionState is GetMonthlyProductionsLoading;

                    final activeWorkers = workersState is GetWorkersSuccess
                        ? workersState.workers
                              .where((worker) => worker.isActive)
                              .length
                        : null;

                    final availableStock = inventoryState is InventoryLoaded
                        ? inventoryState.inventory.fold<int>(
                            0,
                            (sum, item) => sum + item.availableQuantity,
                          )
                        : null;

                    final todayOutgoing = outgoingState is OutgoingRecordsLoaded
                        ? outgoingState.records
                              .where((record) => _isToday(record.date))
                              .fold<int>(
                                0,
                                (sum, record) => sum + record.totalCartons,
                              )
                        : null;

                    final todayProduction =
                        productionState is GetMonthlyProductionsSuccess
                        ? productionState.productions
                              .where((record) => _isToday(record.date))
                              .fold<int>(
                                0,
                                (sum, record) => sum + record.totalCartons,
                              )
                        : null;

                    return GridView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.05,
                          ),
                      children: [
                        DashboardStatCard(
                          title: 'Active Workers',
                          value: workersLoading
                              ? '...'
                              : activeWorkers?.toString() ?? '--',
                          subtitle: workersState is GetWorkersFailure
                              ? 'Could not load workers'
                              : 'Currently active',
                          icon: Icons.groups_rounded,
                          iconColor: ColorManager.navy,
                        ),
                        DashboardStatCard(
                          title: "Today's Production",
                          value: productionLoading
                              ? '...'
                              : todayProduction?.toString() ?? '--',
                          subtitle:
                              productionState is GetMonthlyProductionsFailure
                              ? 'Could not load production'
                              : 'Cartons produced',
                          icon: Icons.inventory_2_rounded,
                          iconColor: ColorManager.primaryLight,
                        ),
                        DashboardStatCard(
                          title: 'Available Stock',
                          value: inventoryLoading
                              ? '...'
                              : availableStock?.toString() ?? '--',
                          subtitle: inventoryState is InventoryError
                              ? 'Could not load inventory'
                              : 'Cartons in inventory',
                          icon: Icons.warehouse_rounded,
                          iconColor: ColorManager.gold,
                        ),
                        DashboardStatCard(
                          title: "Today's Outgoing",
                          value: outgoingLoading
                              ? '...'
                              : todayOutgoing?.toString() ?? '--',
                          subtitle: outgoingState is OutgoingRecordsError
                              ? 'Could not load outgoing'
                              : 'Cartons dispatched',
                          icon: Icons.local_shipping_rounded,
                          iconColor: ColorManager.nutBrown,
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildProductionChart() {
    return BlocBuilder<GetMonthlyProductionsBloc, GetMonthlyProductionsState>(
      builder: (context, state) {
        if (state is GetMonthlyProductionsLoading) {
          return const SizedBox(
            height: 180,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is GetMonthlyProductionsFailure) {
          return const SizedBox(
            height: 100,
            child: Center(child: Text('Could not load production chart.')),
          );
        }

        if (state is GetMonthlyProductionsSuccess) {
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          final firstDay = today.subtract(const Duration(days: 6));

          final days = <String>[];
          final productionData = <double>[];

          const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

          for (int i = 0; i < 7; i++) {
            final day = firstDay.add(Duration(days: i));

            final total = state.productions
                .where(
                  (record) =>
                      record.date.year == day.year &&
                      record.date.month == day.month &&
                      record.date.day == day.day,
                )
                .fold<int>(0, (sum, record) => sum + record.totalCartons);

            days.add(dayNames[day.weekday - 1]);
            productionData.add(total.toDouble());
          }

          return ProductionChart(productionData: productionData, days: days);
        }

        return const SizedBox(
          height: 100,
          child: Center(child: Text('No production data yet.')),
        );
      },
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();

    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

}

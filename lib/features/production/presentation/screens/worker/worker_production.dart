import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:golds_nuts/core/service_locator.dart';
import 'package:golds_nuts/core/utils/color_manager.dart';
import 'package:golds_nuts/features/auth/domain/entities/user_entity.dart';
import 'package:golds_nuts/features/production/presentation/bloc/production/get_monthly_productions/get_monthly_productions_bloc.dart';
import 'package:golds_nuts/features/production/presentation/bloc/production/get_monthly_productions/get_monthly_productions_event.dart';
import 'package:golds_nuts/features/production/presentation/bloc/production/get_monthly_productions/get_monthly_productions_state.dart';
import 'package:golds_nuts/features/production/presentation/screens/worker/add_production_screen.dart';

class WorkerProduction extends StatefulWidget {
  final UserEntity user;

  const WorkerProduction({super.key, required this.user});

  @override
  State<WorkerProduction> createState() => _WorkerProductionState();
}

class _WorkerProductionState extends State<WorkerProduction> {
  late final GetMonthlyProductionsBloc _productionsBloc;

  @override
  void initState() {
    super.initState();

    _productionsBloc = sl<GetMonthlyProductionsBloc>();
    _loadMonthlyProductions();
  }

  void _loadMonthlyProductions() {
    _productionsBloc.add(
      GetMonthlyProductionsRequested(
        month: DateTime.now(),
        workerId: widget.user.uid,
      ),
    );
  }

  Future<void> _openAddProduction() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddProductionScreen(
          workerId: widget.user.uid,
          workerName: widget.user.name,
        ),
      ),
    );

    if (result == true) {
      _loadMonthlyProductions();
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  void dispose() {
    _productionsBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _productionsBloc,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Production'),
          actions: [
            IconButton(
              onPressed: _loadMonthlyProductions,
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        body: BlocBuilder<GetMonthlyProductionsBloc, GetMonthlyProductionsState>(
          builder: (context, state) {
            if (state is GetMonthlyProductionsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is GetMonthlyProductionsFailure) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(state.message),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _loadMonthlyProductions,
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              );
            }

            if (state is GetMonthlyProductionsSuccess) {
              final productions = state.productions;

              final totalCartons = productions.fold<int>(
                0,
                (sum, production) => sum + production.totalCartons,
              );

              final totalAmount = productions.fold<double>(
                0,
                (sum, production) => sum + production.totalAmount,
              );

              final recentProductions = [...productions]
                ..sort((a, b) => b.date.compareTo(a.date));

              return RefreshIndicator(
                onRefresh: () async {
                  _loadMonthlyProductions();
                },
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Text(
                      'Hello, ${widget.user.name}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Here is your production summary for this month.',
                      style: TextStyle(color: ColorManager.textSecondary),
                    ),
                    const SizedBox(height: 24),

                    // Monthly summary
                    Row(
                      children: [
                        Expanded(
                          child: _SummaryCard(
                            title: 'Total Cartons',
                            value: '$totalCartons',
                            icon: Icons.inventory_2_outlined,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SummaryCard(
                            title: 'Total Earnings',
                            value: totalAmount.toStringAsFixed(2),
                            icon: Icons.payments_outlined,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // Recent production
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recent Production',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${productions.length} records',
                          style: TextStyle(color: ColorManager.textSecondary),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    if (recentProductions.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                          child: Text('No production records this month yet.'),
                        ),
                      )
                    else
                      ...recentProductions.take(5).map((production) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Date
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_today_outlined,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _formatDate(production.date),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 16),
                                const Divider(),

                                // Products header
                                const Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        'Product',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        'Quantity',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        'Amount',
                                        textAlign: TextAlign.end,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 12),

                                // Each product
                                ...production.items.map((item) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: Text(
                                            item.productName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            '${item.quantity}',
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            '${item.totalAmount.toStringAsFixed(2)} LE',
                                            textAlign: TextAlign.end,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),

                                const Divider(),

                                // Production totals
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Total Cartons',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '${production.totalCartons}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 8),

                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Total Amount',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      '${production.totalAmount.toStringAsFixed(2)} LE',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: ColorManager.primary,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }),

                    const SizedBox(height: 80),
                  ],
                ),
              );
            }

            return const Center(child: Text('No production data available.'));
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          heroTag: 'add_production',
          onPressed: _openAddProduction,
          icon: const Icon(Icons.add),
          label: const Text('Add Production'),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: ColorManager.primary, size: 28),
            const SizedBox(height: 14),
            Text(
              title,
              style: TextStyle(color: ColorManager.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:golds_nuts/core/service_locator.dart';
import 'package:golds_nuts/core/utils/color_manager.dart';
import 'package:golds_nuts/features/auth/domain/entities/user_entity.dart';
import 'package:golds_nuts/features/product/presentation/bloc/worker/update_worker_status/update_worker_status_bloc.dart';
import 'package:golds_nuts/features/product/presentation/bloc/worker/update_worker_status/update_worker_status_event.dart';
import 'package:golds_nuts/features/product/presentation/bloc/worker/update_worker_status/update_worker_status_state.dart';
import 'package:golds_nuts/features/product/presentation/screens/widgets/worker_info_card.dart';
import 'package:golds_nuts/features/production/domain/entities/production_entity.dart';
import 'package:golds_nuts/features/production/presentation/bloc/production/watch_monthly_productions/watch_monthly_productions_bloc.dart';
import 'package:golds_nuts/features/production/presentation/screens/worker/add_production_screen.dart';

class WorkerDetailsScreen extends StatefulWidget {
  final UserEntity worker;

  const WorkerDetailsScreen({super.key, required this.worker});

  @override
  State<WorkerDetailsScreen> createState() => _WorkerDetailsScreenState();
}

class _WorkerDetailsScreenState extends State<WorkerDetailsScreen> {
  late final WatchMonthlyProductionsBloc _productionsBloc;

  late bool _workerIsActive;

  DateTime _selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();

    _workerIsActive = widget.worker.isActive;

    _productionsBloc = sl<WatchMonthlyProductionsBloc>();

    _watchProductions();
  }

  // Start listening to Firestore production updates.
  void _watchProductions() {
    _productionsBloc.add(
      WatchMonthlyProductionsRequested(
        month: _selectedMonth,
        workerId: widget.worker.uid,
      ),
    );
  }

  void _changeMonth(int offset) {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + offset,
      );
    });

    // Restart the stream with the newly selected month.
    _watchProductions();
  }

  String _monthName(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${months[date.month - 1]} ${date.year}';
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  Future<void> _addProduction() async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddProductionScreen(
          workerId: widget.worker.uid,
          workerName: widget.worker.name,
          canSelectDate: true,
        ),
      ),
    );

    // No manual fetch is needed.
    // Firestore stream will update the screen automatically.
  }

  Future<void> _refreshProductions() async {
    _watchProductions();

    await _productionsBloc.stream.firstWhere(
      (state) =>
          state is WatchMonthlyProductionsSuccess ||
          state is WatchMonthlyProductionsFailure,
    );
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
      child: BlocListener<UpdateWorkerStatusBloc, UpdateWorkerStatusState>(
        listener: (context, state) {
          if (state is UpdateWorkerStatusSuccess) {
            setState(() {
              _workerIsActive = state.isActive;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.isActive
                      ? 'Worker activated successfully'
                      : 'Worker deactivated successfully',
                ),
                backgroundColor: Colors.green,
              ),
            );
          }

          if (state is UpdateWorkerStatusFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(title: const Text('Worker Details')),
          floatingActionButton: FloatingActionButton.extended(
            heroTag: 'worker_details_add_production',
            onPressed: _addProduction,
            icon: const Icon(Icons.add),
            label: const Text('Add Production'),
          ),
          body:
              BlocBuilder<
                WatchMonthlyProductionsBloc,
                WatchMonthlyProductionsState
              >(
                builder: (context, state) {
                  if (state is WatchMonthlyProductionsLoading ||
                      state is WatchMonthlyProductionsInitial) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is WatchMonthlyProductionsFailure) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(state.message),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: _watchProductions,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is WatchMonthlyProductionsSuccess) {
                    final productions = state.productions;

                    final totalCartons = productions.fold<int>(
                      0,
                      (sum, production) => sum + production.totalCartons,
                    );

                    final totalAmount = productions.fold<double>(
                      0,
                      (sum, production) => sum + production.totalAmount,
                    );

                    // Group production records by calendar day.
                    final Map<DateTime, List<ProductionEntity>> grouped = {};

                    for (final production in productions) {
                      final date = production.date;

                      final day = DateTime(date.year, date.month, date.day);

                      grouped.putIfAbsent(day, () => []);
                      grouped[day]!.add(production);
                    }

                    final days = grouped.keys.toList()
                      ..sort((a, b) => b.compareTo(a));

                    return RefreshIndicator(
                      onRefresh: _refreshProductions,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                        children: [
                          WorkerInfoCard(
                            worker: UserEntity(
                              uid: widget.worker.uid,
                              name: widget.worker.name,
                              email: widget.worker.email,
                              role: widget.worker.role,
                              isActive: _workerIsActive,
                            ),
                            onTap: _showWorkerActions,
                          ),

                          const SizedBox(height: 20),

                          _buildMonthSelector(),

                          const SizedBox(height: 16),

                          _buildSummary(
                            totalCartons: totalCartons,
                            totalAmount: totalAmount,
                          ),

                          const SizedBox(height: 24),

                          const Text(
                            'Production History',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 12),

                          if (days.isEmpty)
                            const Padding(
                              padding: EdgeInsets.all(30),
                              child: Center(
                                child: Text(
                                  'No production records for this month',
                                ),
                              ),
                            )
                          else
                            ...days.map(
                              (day) => _buildDayCard(
                                day: day,
                                productions: grouped[day]!,
                              ),
                            ),
                        ],
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
        ),
      ),
    );
  }

  void _showWorkerActions() {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(
                    _workerIsActive
                        ? Icons.person_off_outlined
                        : Icons.person_outline,
                    color: _workerIsActive ? Colors.orange : Colors.green,
                  ),
                  title: Text(
                    _workerIsActive ? 'Deactivate Worker' : 'Activate Worker',
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _confirmWorkerStatusChange();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmWorkerStatusChange() async {
    final newStatus = !_workerIsActive;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(newStatus ? 'Activate Worker?' : 'Deactivate Worker?'),
          content: Text(
            newStatus
                ? 'Are you sure you want to activate this worker?'
                : 'Are you sure you want to deactivate this worker?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: Text(newStatus ? 'Activate' : 'Deactivate'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    context.read<UpdateWorkerStatusBloc>().add(
      UpdateWorkerStatusRequested(
        workerId: widget.worker.uid,
        isActive: newStatus,
      ),
    );
  }

  Widget _buildMonthSelector() {
    final currentMonth = DateTime.now();

    final isCurrentOrFuture =
        _selectedMonth.year > currentMonth.year ||
        (_selectedMonth.year == currentMonth.year &&
            _selectedMonth.month >= currentMonth.month);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => _changeMonth(-1),
          icon: const Icon(Icons.chevron_left),
        ),
        Text(
          _monthName(_selectedMonth),
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        IconButton(
          onPressed: isCurrentOrFuture ? null : () => _changeMonth(1),
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }

  Widget _buildSummary({
    required int totalCartons,
    required double totalAmount,
  }) {
    return Row(
      children: [
        Expanded(
          child: _summaryCard(
            title: 'Total Cartons',
            value: '$totalCartons',
            icon: Icons.inventory_2_outlined,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _summaryCard(
            title: 'Total Earnings',
            value: '${totalAmount.toStringAsFixed(2)} LE',
            icon: Icons.payments_outlined,
          ),
        ),
      ],
    );
  }

  Widget _summaryCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: ColorManager.gold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayCard({
    required DateTime day,
    required List<ProductionEntity> productions,
  }) {
    final dayCartons = productions.fold<int>(
      0,
      (sum, production) => sum + production.totalCartons,
    );

    final dayAmount = productions.fold<double>(
      0,
      (sum, production) => sum + production.totalAmount,
    );

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _formatDate(day),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '$dayCartons Cartons',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),

            const SizedBox(height: 5),

            Text(
              'Total: ${dayAmount.toStringAsFixed(2)} LE',
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.w600,
              ),
            ),

            const Divider(height: 22),

            ...productions.expand(
              (production) => production.items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.inventory_2_outlined, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.productName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${item.quantity} cartons × '
                              '${item.pricePerCarton.toStringAsFixed(2)} LE',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${item.totalAmount.toStringAsFixed(2)} LE',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

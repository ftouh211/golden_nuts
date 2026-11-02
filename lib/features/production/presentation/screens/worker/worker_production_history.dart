
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:golds_nuts/core/service_locator.dart';
import 'package:golds_nuts/core/utils/color_manager.dart';
import 'package:golds_nuts/features/auth/domain/entities/user_entity.dart';
import 'package:golds_nuts/features/production/domain/entities/production_entity.dart';
import 'package:golds_nuts/features/production/presentation/bloc/production/get_monthly_productions/get_monthly_productions_bloc.dart';
import 'package:golds_nuts/features/production/presentation/bloc/production/get_monthly_productions/get_monthly_productions_event.dart';
import 'package:golds_nuts/features/production/presentation/bloc/production/get_monthly_productions/get_monthly_productions_state.dart';

class WorkerProductionHistory extends StatefulWidget {
  final UserEntity user;

  const WorkerProductionHistory({
    super.key,
    required this.user,
  });

  @override
  State<WorkerProductionHistory> createState() =>
      _WorkerProductionHistoryState();
}

class _WorkerProductionHistoryState
    extends State<WorkerProductionHistory> {
  late final GetMonthlyProductionsBloc _productionsBloc;

  DateTime _selectedMonth = DateTime.now();

  @override
  void initState() {
    super.initState();

    _productionsBloc = sl<GetMonthlyProductionsBloc>();
    _loadProductions();
  }

  void _loadProductions() {
    _productionsBloc.add(
      GetMonthlyProductionsRequested(
        month: _selectedMonth,
        workerId: widget.user.uid,
      ),
    );
  }

  void _changeMonth(int offset) {
    final newMonth = DateTime(
      _selectedMonth.year,
      _selectedMonth.month + offset,
    );

    // منع الانتقال إلى شهر مستقبلي
    final currentMonth = DateTime.now();

    if (newMonth.year > currentMonth.year ||
        (newMonth.year == currentMonth.year &&
            newMonth.month > currentMonth.month)) {
      return;
    }

    setState(() {
      _selectedMonth = newMonth;
    });

    _loadProductions();
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
        backgroundColor: ColorManager.background,
        appBar: AppBar(
          title: const Text('Production History'),
        ),
        body: BlocBuilder<GetMonthlyProductionsBloc,
            GetMonthlyProductionsState>(
          builder: (context, state) {
            if (state is GetMonthlyProductionsLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (state is GetMonthlyProductionsFailure) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(state.message),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _loadProductions,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state is GetMonthlyProductionsSuccess) {
              final productions = state.productions;

              return _buildHistoryContent(productions);
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildHistoryContent(List<ProductionEntity> productions) {
    final groupedDays = _groupProductionsByDay(productions);

    final totalCartons = productions.fold<int>(
      0,
          (sum, production) => sum + production.totalCartons,
    );

    final totalAmount = productions.fold<double>(
      0,
          (sum, production) => sum + production.totalAmount,
    );

    return Column(
      children: [
        _buildMonthSelector(),

        _buildMonthlySummary(
          totalCartons: totalCartons,
          totalAmount: totalAmount,
        ),

        Expanded(
          child: groupedDays.isEmpty
              ? const Center(
            child: Text('No production records for this month'),
          )
              : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: groupedDays.length,
            itemBuilder: (context, index) {
              final day = groupedDays[index];

              return _buildDayCard(day);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMonthSelector() {
    final isCurrentMonth =
        _selectedMonth.year == DateTime.now().year &&
            _selectedMonth.month == DateTime.now().month;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => _changeMonth(-1),
            icon: const Icon(Icons.chevron_left),
          ),
          Text(
            DateFormat('MMMM yyyy').format(_selectedMonth),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            onPressed: isCurrentMonth ? null : () => _changeMonth(1),
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlySummary({
    required int totalCartons,
    required double totalAmount,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: _summaryItem(
                title: 'Total Cartons',
                value: totalCartons.toString(),
                icon: Icons.inventory_2_outlined,
              ),
            ),
            Container(
              width: 1,
              height: 45,
              color: Colors.grey.shade300,
            ),
            Expanded(
              child: _summaryItem(
                title: 'Total Earnings',
                value: '${totalAmount.toStringAsFixed(2)} EGP',
                icon: Icons.payments_outlined,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryItem({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, color: ColorManager.primary),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  List<_DayProduction> _groupProductionsByDay(
      List<ProductionEntity> productions,
      ) {
    final Map<String, _DayProduction> days = {};

    for (final production in productions) {
      final date = production.date;

      final key = '${date.year}-${date.month}-${date.day}';

      final day = days.putIfAbsent(
        key,
            () => _DayProduction(date: date),
      );

      day.totalCartons += production.totalCartons;
      day.totalAmount += production.totalAmount;

      for (final item in production.items) {
        day.items.add(item);
      }
    }

    final result = days.values.toList();

    result.sort((a, b) => b.date.compareTo(a.date));

    return result;
  }

  Widget _buildDayCard(_DayProduction day) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 18),
                const SizedBox(width: 8),
                Text(
                  DateFormat('EEEE, dd MMM yyyy').format(day.date),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),

            const Divider(height: 24),

            const Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Product',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Qty',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Amount',
                    textAlign: TextAlign.end,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            ...day.items.map(
                  (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(item.productName),
                    ),
                    Expanded(
                      child: Text(
                        item.quantity.toString(),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        item.totalAmount.toStringAsFixed(2),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Divider(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Cartons: ${day.totalCartons}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${day.totalAmount.toStringAsFixed(2)} EGP',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: ColorManager.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DayProduction {
  final DateTime date;
  final List<ProductionItemEntity> items = [];

  int totalCartons = 0;
  double totalAmount = 0;

  _DayProduction({required this.date});
}

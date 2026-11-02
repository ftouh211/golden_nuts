import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:golds_nuts/core/service_locator.dart';
import 'package:golds_nuts/features/product/presentation/bloc/worker/create_worker/create_worker_bloc.dart';
import 'package:golds_nuts/features/product/presentation/bloc/worker/get_worker/get_workers_bloc.dart';
import 'package:golds_nuts/features/product/presentation/bloc/worker/get_worker/get_workers_event.dart';
import 'package:golds_nuts/features/product/presentation/bloc/worker/get_worker/get_workers_state.dart';
import 'package:golds_nuts/features/product/presentation/bloc/worker/update_worker_status/update_worker_status_bloc.dart';
import 'package:golds_nuts/features/product/presentation/screens/widgets/add_worker_dialog.dart';
import 'package:golds_nuts/features/product/presentation/screens/worker_details_screen.dart';
import 'package:golds_nuts/features/production/presentation/bloc/production/get_monthly_productions/get_monthly_productions_bloc.dart';
import 'package:golds_nuts/features/production/presentation/bloc/production/get_monthly_productions/get_monthly_productions_event.dart';
import 'package:golds_nuts/features/production/presentation/bloc/production/get_monthly_productions/get_monthly_productions_state.dart';

class CreateWorker extends StatelessWidget {
  const CreateWorker({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<CreateWorkerBloc>()),
        BlocProvider(
          create: (_) => sl<GetWorkersBloc>()..add(const GetWorkersRequested()),
        ),
        BlocProvider(
          create: (_) =>
              sl<GetMonthlyProductionsBloc>()
                ..add(GetMonthlyProductionsRequested(month: DateTime.now())),
        ),
      ],
      child: const CreateWorkerView(),
    );
  }
}

class CreateWorkerView extends StatelessWidget {
  const CreateWorkerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Workers Management')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Workers List',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    final createWorkerBloc = context.read<CreateWorkerBloc>();

                    showDialog(
                      context: context,
                      builder: (dialogContext) {
                        return BlocProvider.value(
                          value: createWorkerBloc,
                          child: AddWorkerDialog(
                            onSuccess: () {
                              Navigator.pop(dialogContext);

                              context.read<GetWorkersBloc>().add(
                                const GetWorkersRequested(),
                              );

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Worker added successfully'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Worker'),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Expanded(
              child: BlocBuilder<GetWorkersBloc, GetWorkersState>(
                builder: (context, workerState) {
                  if (workerState is GetWorkersLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (workerState is GetWorkersFailure) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(workerState.message),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () {
                              context.read<GetWorkersBloc>().add(
                                const GetWorkersRequested(),
                              );
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (workerState is GetWorkersSuccess) {
                    if (workerState.workers.isEmpty) {
                      return const Center(child: Text('No workers found'));
                    }

                    return BlocBuilder<
                      GetMonthlyProductionsBloc,
                      GetMonthlyProductionsState
                    >(
                      builder: (context, productionState) {
                        // إجمالي الكراتين لكل عامل
                        final Map<String, int> cartonsByWorker = {};

                        // إجمالي المستحقات لكل عامل
                        final Map<String, double> earningsByWorker = {};

                        if (productionState is GetMonthlyProductionsSuccess) {
                          for (final production
                              in productionState.productions) {
                            final workerId = production.workerId;

                            cartonsByWorker[workerId] =
                                (cartonsByWorker[workerId] ?? 0) +
                                production.totalCartons;

                            earningsByWorker[workerId] =
                                (earningsByWorker[workerId] ?? 0) +
                                production.totalAmount;
                          }
                        }

                        return ListView.builder(
                          itemCount: workerState.workers.length,
                          itemBuilder: (context, index) {
                            final worker = workerState.workers[index];

                            final totalCartons =
                                cartonsByWorker[worker.uid] ?? 0;

                            final totalEarnings =
                                earningsByWorker[worker.uid] ?? 0.0;

                            return Card(
                              margin: const EdgeInsets.only(bottom: 14),
                              elevation: 2,
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  children: [
                                    ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      leading: CircleAvatar(
                                        radius: 25,
                                        child: Text(
                                          worker.name.isNotEmpty
                                              ? worker.name[0].toUpperCase()
                                              : '?',
                                        ),
                                      ),
                                      title: Text(
                                        worker.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17,
                                        ),
                                      ),
                                      subtitle: Text(worker.email),
                                      trailing: const Icon(
                                        Icons.arrow_forward_ios,
                                        size: 16,
                                      ),
                                      onTap: () async {
                                        final result =
                                            await Navigator.push<bool>(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => BlocProvider(
                                                  create: (_) =>
                                                      sl<
                                                        UpdateWorkerStatusBloc
                                                      >(),
                                                  child: WorkerDetailsScreen(
                                                    worker: worker,
                                                  ),
                                                ),
                                              ),
                                            );

                                        if (context.mounted) {
                                          context.read<GetWorkersBloc>().add(
                                            GetWorkersRequested(),
                                          );
                                        }
                                      },
                                    ),

                                    const Divider(),

                                    if (productionState
                                            is GetMonthlyProductionsLoading ||
                                        productionState
                                            is GetMonthlyProductionsInitial)
                                      Row(
                                        children: const [
                                          Expanded(
                                            child: _WorkerStat(
                                              title: 'Monthly Production',
                                              value: '',
                                              subtitle: 'Loading...',
                                              icon: Icons.inventory_2_outlined,
                                              isLoading: true,
                                            ),
                                          ),
                                          SizedBox(width: 12),
                                          Expanded(
                                            child: _WorkerStat(
                                              title: 'Monthly Earnings',
                                              value: '',
                                              subtitle: 'Loading...',
                                              icon: Icons.payments_outlined,
                                              isLoading: true,
                                            ),
                                          ),
                                        ],
                                      )
                                    else if (productionState
                                        is GetMonthlyProductionsFailure)
                                      const Padding(
                                        padding: EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                        child: Row(
                                          children: [
                                            Icon(
                                              Icons.error_outline,
                                              color: Colors.red,
                                            ),
                                            SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                'Could not load production data',
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    else
                                      Row(
                                        children: [
                                          Expanded(
                                            child: _WorkerStat(
                                              title: 'Monthly Production',
                                              value: '$totalCartons',
                                              subtitle: 'Cartons',
                                              icon: Icons.inventory_2_outlined,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: _WorkerStat(
                                              title: 'Monthly Earnings',
                                              value: totalEarnings
                                                  .toStringAsFixed(2),
                                              subtitle: 'EGP',
                                              icon: Icons.payments_outlined,
                                            ),
                                          ),
                                        ],
                                      ),

                                    // if (productionState
                                    // is GetMonthlyProductionsLoading ||
                                    //     productionState
                                    //     is GetMonthlyProductionsInitial)
                                    //   const LinearProgressIndicator()
                                    // else if (productionState
                                    // is GetMonthlyProductionsFailure)
                                    //   const Text(
                                    //     'Could not load production data',
                                    //     style: TextStyle(color: Colors.red),
                                    //   )
                                    // else
                                    //   Row(
                                    //     children: [
                                    //       Expanded(
                                    //         child: _WorkerStat(
                                    //           title: 'Monthly Production',
                                    //           value: '$totalCartons',
                                    //           subtitle: 'Cartons',
                                    //           icon: Icons.inventory_2_outlined,
                                    //         ),
                                    //       ),
                                    //       const SizedBox(width: 12),
                                    //       Expanded(
                                    //         child: _WorkerStat(
                                    //           title: 'Monthly Earnings',
                                    //           value: totalEarnings
                                    //               .toStringAsFixed(2),
                                    //           subtitle: 'EGP',
                                    //           icon: Icons.payments_outlined,
                                    //         ),
                                    //       ),
                                    //     ],
                                    //   ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkerStat extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final bool isLoading;

  const _WorkerStat({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: colorScheme.primary),

          const SizedBox(height: 8),

          Text(
            title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),

          const SizedBox(height: 8),

          if (isLoading)
            const SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            )
          else
            Text(
              value,
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),

          const SizedBox(height: 5),

          Text(
            subtitle,
            style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

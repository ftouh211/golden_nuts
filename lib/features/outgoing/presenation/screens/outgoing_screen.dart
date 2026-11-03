import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:golds_nuts/core/service_locator.dart';
import 'package:golds_nuts/core/utils/color_manager.dart';
import 'package:golds_nuts/features/inventory/presentation/bloc/inventory_bloc.dart';
import 'package:golds_nuts/features/inventory/presentation/bloc/inventory_event.dart';
import 'package:golds_nuts/features/inventory/presentation/bloc/inventory_state.dart';
import 'package:golds_nuts/features/inventory/presentation/screens/widgets/available_quantity_card.dart';
import 'package:golds_nuts/features/outgoing/presenation/bloc/outgoing_bloc.dart';
import 'package:golds_nuts/features/outgoing/presenation/bloc/outgoing_event.dart';
import 'package:golds_nuts/features/outgoing/presenation/bloc/outgoing_state.dart';
import 'package:golds_nuts/features/outgoing/presenation/screens/add_outgoing_screen.dart';
import 'package:golds_nuts/features/outgoing/presenation/screens/widget/outgoing_statistics.dart';
import 'package:golds_nuts/features/product/presentation/bloc/product_bloc.dart';
import 'package:golds_nuts/features/product/presentation/bloc/product_event.dart';
import 'package:golds_nuts/features/product/presentation/bloc/product_state.dart';

class OutgoingScreen extends StatelessWidget {
  const OutgoingScreen({super.key});

  Future<void> _openAddOutgoing(BuildContext context) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AddOutgoingScreen()),
    );

    if (!context.mounted) return;

    if (result == true) {
      context.read<OutgoingBloc>().add(GetOutgoingRecordsEvent());

      context.read<InventoryBloc>().add(GetInventoryEvent());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Outgoing record added successfully.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => sl<OutgoingBloc>()..add(GetOutgoingRecordsEvent()),
        ),
        BlocProvider(
          create: (_) =>
              sl<ProductBloc>()..add(GetProductsEvent(activeOnly: true)),
        ),
        BlocProvider(
          create: (_) => sl<InventoryBloc>()..add(GetInventoryEvent()),
        ),
      ],
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(title: const Text('Outgoing')),
            body: BlocBuilder<OutgoingBloc, OutgoingState>(
              builder: (context, state) {
                if (state is OutgoingRecordsLoading ||
                    state is OutgoingInitial) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is OutgoingRecordsError) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(state.message),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () {
                            context.read<OutgoingBloc>().add(
                              GetOutgoingRecordsEvent(),
                            );
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is OutgoingRecordsLoaded) {
                  final statistics = OutgoingStatistics.fromRecords(
                    state.records,
                  );

                  return _OutgoingDashboardContent(statistics: statistics);
                }

                return const SizedBox.shrink();
              },
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => _openAddOutgoing(context),
              backgroundColor: ColorManager.gold,
              foregroundColor: ColorManager.textPrimary,
              icon: const Icon(Icons.add),
              label: const Text('Add Outgoing'),
            ),
          );
        },
      ),
    );
  }
}

class _OutgoingDashboardContent extends StatelessWidget {
  final OutgoingStatistics statistics;

  const _OutgoingDashboardContent({required this.statistics});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<OutgoingBloc>().add(GetOutgoingRecordsEvent());
        context.read<InventoryBloc>().add(GetInventoryEvent());
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSalesCard(),

          const SizedBox(height: 24),

          const Text(
            'Products Summary',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          _buildProductsSummary(),

          const SizedBox(height: 24),

          const Text(
            'Recent Outgoing',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          if (statistics.recentRecords.isEmpty)
            const Text('No outgoing records yet.')
          else
            ...statistics.recentRecords.map(
              (record) => Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.local_shipping_outlined),
                  ),
                  subtitle: Text(
                    'Delivered by: ${record.deliveredBy}\n'
                    'Received by: ${record.receivedBy}\n'
                    '${record.totalCartons} cartons',
                  ),
                  isThreeLine: false,
                  trailing: Text(
                    '${record.totalAmount.toStringAsFixed(2)} EGP',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductsSummary() {
    if (statistics.products.isEmpty) {
      return const Text('No outgoing products yet.');
    }

    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, productState) {
        if (productState is! ProductsLoaded) {
          return const Center(child: CircularProgressIndicator());
        }

        final products = productState.products;

        return BlocBuilder<InventoryBloc, InventoryState>(
          builder: (context, inventoryState) {
            if (inventoryState is InventoryLoading ||
                inventoryState is InventoryInitial) {
              return const Center(child: CircularProgressIndicator());
            }

            if (inventoryState is InventoryError) {
              return Text(inventoryState.message);
            }

            if (inventoryState is! InventoryLoaded) {
              return const SizedBox.shrink();
            }

            final inventory = inventoryState.inventory;

            return LayoutBuilder(
              builder: (context, constraints) {
                const spacing = 12.0;
                final cardWidth = (constraints.maxWidth - spacing) / 2;

                return Wrap(
                  spacing: spacing,
                  runSpacing: spacing,
                  children: statistics.products.map((product) {
                    return SizedBox(
                      width: cardWidth,
                      child: Card(
                        margin: EdgeInsets.zero,
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                product.productName,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),

                              const Divider(height: 16),

                              const Text(
                                'Available Stock',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),

                              const SizedBox(height: 4),

                              AvailableQuantityCard(
                                inventory: inventory,
                                products: products,
                                productId: product.productId,
                              ),

                              const SizedBox(height: 8),

                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Outgoing',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          '${product.quantity} cartons',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(width: 6),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Total Amount',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          '${product.totalAmount.toStringAsFixed(0)} EGP',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildSalesCard() {
    return Card(
      color: ColorManager.gold,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Total Sales',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),

            const SizedBox(height: 12),

            Text(
              '${statistics.totalSales.toStringAsFixed(2)} EGP',
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 4),

            const Text('Since the beginning'),
          ],
        ),
      ),
    );
  }
}

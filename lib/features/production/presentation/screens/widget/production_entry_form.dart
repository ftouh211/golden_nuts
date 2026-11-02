import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:golds_nuts/core/service_locator.dart';

import 'package:golds_nuts/features/product/domain/entities/product_entity.dart';
import 'package:golds_nuts/features/product/presentation/bloc/product_bloc.dart';
import 'package:golds_nuts/features/product/presentation/bloc/product_event.dart';
import 'package:golds_nuts/features/product/presentation/bloc/product_state.dart';

import 'package:golds_nuts/features/production/domain/entities/production_entity.dart';
import 'package:golds_nuts/features/production/presentation/bloc/production/add_production/add_production_bloc.dart';
import 'package:golds_nuts/features/production/presentation/bloc/production/add_production/add_production_event.dart';
import 'package:golds_nuts/features/production/presentation/bloc/production/add_production/add_production_state.dart';


class ProductionEntryForm extends StatelessWidget {
  final String workerId;
  final String workerName;
  final bool canSelectDate;
  final VoidCallback? onSuccess;

  const ProductionEntryForm({
    super.key,
    required this.workerId,
    required this.workerName,
    this.canSelectDate = false,
    this.onSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
          sl<ProductBloc>()..add(const GetProductsEvent(activeOnly: true)),
        ),
        BlocProvider(create: (_) => sl<AddProductionBloc>()),
      ],
      child: _ProductionEntryContent(
        workerId: workerId,
        workerName: workerName,
        canSelectDate: canSelectDate,
        onSuccess: onSuccess,
      ),
    );
  }
}


class _ProductionEntryContent extends StatefulWidget {
  final String workerId;
  final String workerName;
  final bool canSelectDate;
  final VoidCallback? onSuccess;

  const _ProductionEntryContent({
    required this.workerId,
    required this.workerName,
    required this.canSelectDate,
    required this.onSuccess,
  });

  @override
  State<_ProductionEntryContent> createState() =>
      _ProductionEntryContentState();
}
class _ProductionEntryContentState extends State<_ProductionEntryContent> {
  final List<_ProductionRow> _rows = [_ProductionRow()];
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    for (final row in _rows) {
      row.quantityController.dispose();
    }
    super.dispose();
  }

  void _addRow() {
    setState(() {
      _rows.add(_ProductionRow());
    });
  }

  void _removeRow(int index) {
    if (_rows.length == 1) return;

    setState(() {
      _rows[index].quantityController.dispose();
      _rows.removeAt(index);
    });
  }

  int get _totalCartons {
    return _rows.fold(0, (total, row) {
      return total + (int.tryParse(row.quantityController.text) ?? 0);
    });
  }

  double get _totalAmount {
    return _rows.fold(0.0, (total, row) {
      final quantity = int.tryParse(row.quantityController.text) ?? 0;

      final price = row.product?.pricePerCarton ?? 0;

      return total + (quantity * price);
    });
  }

  void _saveProduction() {
    final items = <ProductionItemEntity>[];

    for (var i = 0; i < _rows.length; i++) {
      final row = _rows[i];
      final quantity = int.tryParse(row.quantityController.text.trim());

      if (row.product == null) {
        _showMessage('Please select a product in row ${i + 1}');
        return;
      }

      if (quantity == null || quantity <= 0) {
        _showMessage('Enter a valid quantity in row ${i + 1}');
        return;
      }

      final product = row.product!;

      items.add(
        ProductionItemEntity(
          productId: product.id,
          productName: product.name,
          quantity: quantity,
          pricePerCarton: product.pricePerCarton,
          totalAmount: quantity * product.pricePerCarton,
        ),
      );
    }

    final now = DateTime.now();

    final production = ProductionEntity(
      id: '',
      workerId: widget.workerId,
      workerName: widget.workerName,
      date: _selectedDate,
      items: items,
      totalCartons: _totalCartons,
      totalAmount: _totalAmount,
      createdAt: now,
    );

    context.read<AddProductionBloc>().add(
      AddProductionRequested(production: production),
    );
  }

  void _resetForm() {
    for (final row in _rows) {
      row.quantityController.dispose();
    }

    setState(() {
      _rows
        ..clear()
        ..add(_ProductionRow());
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _selectDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (selected != null) {
      setState(() {
        _selectedDate = selected;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return BlocListener<AddProductionBloc, AddProductionState>(
      listener: (context, state) {
        if (state is AddProductionSuccess) {
          if (widget.onSuccess != null) {
            widget.onSuccess!();
          } else {
            _resetForm();
            _showMessage('Production saved successfully!');
          }
        }

        if (state is AddProductionFailure) {
          _showMessage(state.message);
        }
      },
      child: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state is ProductLoading || state is ProductInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProductFailure) {
            return Center(child: Text(state.message));
          }

          if (state is ProductsLoaded) {
            final products = state.products;

            if (products.isEmpty) {
              return const Center(child: Text('No active products available'));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Record Production',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text('Worker: ${widget.workerName}'),
                  const SizedBox(height: 16),

                  if (widget.canSelectDate) ...[
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.calendar_month),
                      title: const Text('Production Date'),
                      subtitle: Text(
                        MaterialLocalizations.of(context).formatMediumDate(_selectedDate),
                      ),
                      trailing: const Icon(Icons.edit_calendar),
                      onTap: _selectDate,
                    ),
                    const SizedBox(height: 16),
                  ],

                  ...List.generate(_rows.length, (index) {
                    return _buildProductRow(index: index, products: products);
                  }),

                  const SizedBox(height: 12),

                  OutlinedButton.icon(
                    onPressed: _addRow,
                    icon: const Icon(Icons.add),
                    label: const Text('Add another product'),
                  ),

                  const SizedBox(height: 24),
                  const Divider(),

                  _buildSummary(),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildProductRow({
    required int index,
    required List<ProductEntity> products,
  }) {
    final row = _rows[index];

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Product ${index + 1}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                if (_rows.length > 1)
                  IconButton(
                    onPressed: () => _removeRow(index),
                    icon: const Icon(Icons.delete_outline),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            DropdownButtonFormField<ProductEntity>(
              value: row.product,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Select product',
                border: OutlineInputBorder(),
              ),
              items: products.map((product) {
                return DropdownMenuItem<ProductEntity>(
                  value: product,
                  child: Text(product.name),
                );
              }).toList(),
              onChanged: (product) {
                setState(() {
                  row.product = product;
                });
              },
            ),

            const SizedBox(height: 12),

            TextFormField(
              controller: row.quantityController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Cartons quantity',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) {
                setState(() {});
              },
            ),

            const SizedBox(height: 12),

            if (row.product != null)
              Text('Price per carton: ${row.product!.pricePerCarton} LE'),

            const SizedBox(height: 4),

            Text(
              'Product total: ${_getRowTotal(row).toStringAsFixed(2)} LE',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  double _getRowTotal(_ProductionRow row) {
    final quantity = int.tryParse(row.quantityController.text) ?? 0;

    final price = row.product?.pricePerCarton ?? 0;

    return quantity * price;
  }

  Widget _buildSummary() {
    return BlocBuilder<AddProductionBloc, AddProductionState>(
      builder: (context, state) {
        final isLoading = state is AddProductionLoading;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total cartons: $_totalCartons'),
            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: Text(
                    'Total amount: ${_totalAmount.toStringAsFixed(2)} LE',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                ElevatedButton.icon(
                  onPressed: isLoading ? null : _saveProduction,
                  icon: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: Text(isLoading ? 'Saving...' : 'Save'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _ProductionRow {
  ProductEntity? product;

  final TextEditingController quantityController = TextEditingController();
}

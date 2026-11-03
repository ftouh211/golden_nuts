import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:golds_nuts/core/service_locator.dart';
import 'package:golds_nuts/features/inventory/domain/entities/inventory_entity.dart';
import 'package:golds_nuts/features/inventory/presentation/bloc/inventory_bloc.dart';
import 'package:golds_nuts/features/inventory/presentation/bloc/inventory_event.dart';
import 'package:golds_nuts/features/inventory/presentation/bloc/inventory_state.dart';
import 'package:golds_nuts/features/inventory/presentation/screens/widgets/available_quantity_card.dart';
import 'package:golds_nuts/features/outgoing/presenation/bloc/outgoing_bloc.dart';
import 'package:golds_nuts/features/outgoing/presenation/bloc/outgoing_event.dart';
import 'package:golds_nuts/features/outgoing/presenation/bloc/outgoing_state.dart';
import 'package:golds_nuts/features/product/domain/entities/product_entity.dart';
import 'package:golds_nuts/features/product/presentation/bloc/product_bloc.dart';
import 'package:golds_nuts/features/product/presentation/bloc/product_event.dart';
import 'package:golds_nuts/features/product/presentation/bloc/product_state.dart';

class AddOutgoingScreen extends StatefulWidget {
  const AddOutgoingScreen({super.key});

  @override
  State<AddOutgoingScreen> createState() => _AddOutgoingScreenState();
}

class _AddOutgoingScreenState extends State<AddOutgoingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _deliveredByController = TextEditingController();
  final _receivedByController = TextEditingController();
  final _directionController = TextEditingController();
  final _quantityController = TextEditingController();
  final _orderAmountController = TextEditingController();
  String? _selectedProductId;

  final List<Map<String, dynamic>> _selectedItems = [];

  @override
  void dispose() {
    _deliveredByController.dispose();
    _receivedByController.dispose();
    _directionController.dispose();
    _quantityController.dispose();
    _orderAmountController.dispose();
    super.dispose();
  }

  void _addProduct({
    required List<ProductEntity> products,
    required List<InventoryEntity> inventory,
  }) {
    if (_selectedProductId == null) {
      _showMessage('Please select a product.');
      return;
    }

    final quantity = int.tryParse(_quantityController.text);
    final orderAmount = double.tryParse(_orderAmountController.text);

    if (quantity == null || quantity <= 0) {
      _showMessage('Please enter a valid quantity.');
      return;
    }

    if (orderAmount == null || orderAmount <= 0) {
      _showMessage('Please enter a valid order amount.');
      return;
    }

    final product = products.firstWhere(
      (item) => item.id == _selectedProductId,
    );

    final inventoryItem = inventory.where(
      (item) => item.productId == product.id,
    );

    final availableQuantity = inventoryItem.isNotEmpty
        ? inventoryItem.first.availableQuantity
        : 0;

    final alreadySelected = _selectedItems
        .where((item) => item['productId'] == product.id)
        .fold<int>(0, (sum, item) => sum + (item['quantity'] as int));

    final remainingQuantity = availableQuantity - alreadySelected;

    if (quantity > remainingQuantity) {
      _showMessage('Available quantity is $remainingQuantity cartons.');
      return;
    }

    setState(() {
      final existingIndex = _selectedItems.indexWhere(
        (item) => item['productId'] == product.id,
      );

      if (existingIndex != -1) {
        _selectedItems[existingIndex]['quantity'] += quantity;
        _selectedItems[existingIndex]['orderAmount'] += orderAmount;
      } else {
        _selectedItems.add({
          'productId': product.id,
          'productName': product.name,
          'quantity': quantity,
          'orderAmount': orderAmount,
        });
      }

      _quantityController.clear();
      _orderAmountController.clear();
      _selectedProductId = null;
    });
  }

  void _removeProduct(int index) {
    setState(() {
      _selectedItems.removeAt(index);
    });
  }

  void _submitOutgoing(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedItems.isEmpty) {
      _showMessage('Please add at least one product.');
      return;
    }

    final data = {
      'date': DateTime.now().toIso8601String(),
      'deliveredBy': _deliveredByController.text.trim(),
      'receivedBy': _receivedByController.text.trim(),
      'direction': _directionController.text.trim(),
      'items': _selectedItems.map((item) {
        return {
          'productId': item['productId'],
          'quantity': item['quantity'],
          'orderAmount': item['orderAmount'],
        };
      }).toList(),
    };

    context.read<OutgoingBloc>().add(AddOutgoingEvent(data: data));
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              sl<ProductBloc>()..add(GetProductsEvent(activeOnly: true)),
        ),
        BlocProvider(
          create: (_) => sl<InventoryBloc>()..add(GetInventoryEvent()),
        ),
        BlocProvider(create: (_) => sl<OutgoingBloc>()),
      ],
      child: BlocListener<OutgoingBloc, OutgoingState>(
        listener: (context, state) {
          if (state is OutgoingSuccess) {
            _showMessage('Outgoing record added successfully.');
            Navigator.pop(context, true);

            _deliveredByController.clear();
            _receivedByController.clear();
            _directionController.clear();
            _orderAmountController.clear();
            _quantityController.clear();
          }

          if (state is OutgoingError) {
            _showMessage(state.message);
          }
        },
        child: Scaffold(
          appBar: AppBar(title: const Text('Outgoing')),
          body: Form(
            key: _formKey,
            child: BlocBuilder<ProductBloc, ProductState>(
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
                      return Center(child: Text(inventoryState.message));
                    }

                    if (inventoryState is! InventoryLoaded) {
                      return const SizedBox.shrink();
                    }

                    final inventory = inventoryState.inventory;

                    return BlocBuilder<OutgoingBloc, OutgoingState>(
                      builder: (context, outgoingState) {
                        final isLoading = outgoingState is OutgoingLoading;

                        return SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle('Outgoing Information'),

                              const SizedBox(height: 16),

                              _buildTextField(
                                controller: _deliveredByController,
                                label: 'Delivered By',
                              ),

                              const SizedBox(height: 12),

                              _buildTextField(
                                controller: _receivedByController,
                                label: 'Received By',
                              ),

                              const SizedBox(height: 12),

                              _buildTextField(
                                controller: _directionController,
                                label: 'Direction',
                              ),

                              const SizedBox(height: 28),

                              _buildSectionTitle('Select Products'),

                              const SizedBox(height: 12),

                              DropdownButtonFormField<String>(
                                value: _selectedProductId,
                                decoration: const InputDecoration(
                                  labelText: 'Product',
                                  border: OutlineInputBorder(),
                                ),
                                items: products.map((product) {
                                  return DropdownMenuItem<String>(
                                    value: product.id,
                                    child: Text(product.name),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedProductId = value;
                                  });
                                },
                              ),

                              if (_selectedProductId != null)
                                AvailableQuantityCard(
                                  inventory: inventory,
                                  products: products,
                                  productId: _selectedProductId,
                                  alreadySelectedQuantity: _selectedItems
                                      .where(
                                        (item) =>
                                            item['productId'] ==
                                            _selectedProductId,
                                      )
                                      .fold<int>(
                                        0,
                                        (sum, item) =>
                                            sum + (item['quantity'] as int),
                                      ),
                                ),

                              const SizedBox(height: 12),

                              TextFormField(
                                controller: _quantityController,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  labelText: 'Quantity (Cartons)',
                                  border: OutlineInputBorder(),
                                ),
                              ),

                              const SizedBox(height: 12),

                              TextFormField(
                                controller: _orderAmountController,
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                decoration: const InputDecoration(
                                  labelText: 'Order Amount (EGP)',
                                  hintText:
                                      'Enter total price for this product',
                                  border: OutlineInputBorder(),
                                  prefixText: 'EGP ',
                                ),
                              ),
                              const SizedBox(height: 12),

                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    _addProduct(
                                      products: products,
                                      inventory: inventory,
                                    );
                                  },
                                  icon: const Icon(Icons.add),
                                  label: const Text('Add Product'),
                                ),
                              ),

                              const SizedBox(height: 28),

                              _buildSectionTitle('Selected Products'),

                              const SizedBox(height: 12),

                              if (_selectedItems.isEmpty)
                                const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(20),
                                    child: Text('No products selected yet.'),
                                  ),
                                )
                              else
                                ..._selectedItems.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final item = entry.value;

                                  return Card(
                                    child: ListTile(
                                      title: Text(item['productName']),
                                      subtitle: Text(
                                        'Quantity: ${item['quantity']} cartons\n'
                                        'Order Amount: ${item['orderAmount']} EGP',
                                      ),
                                      trailing: IconButton(
                                        icon: const Icon(
                                          Icons.delete_outline,
                                          color: Colors.red,
                                        ),
                                        onPressed: () {
                                          _removeProduct(index);
                                        },
                                      ),
                                    ),
                                  );
                                }),

                              const SizedBox(height: 16),

                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Total Order Amount: '
                                  '${_selectedItems.fold<double>(0, (sum, item) => sum + (item['orderAmount'] as double))} EGP',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: isLoading
                                    ? null
                                    : () => _submitOutgoing(context),
                                style: ElevatedButton.styleFrom(
                                  minimumSize: const Size(double.infinity, 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: isLoading
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text('Save Outgoing'),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'This field is required.';
        }
        return null;
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }
}

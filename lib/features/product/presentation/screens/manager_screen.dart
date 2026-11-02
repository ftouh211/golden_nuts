
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:golds_nuts/core/service_locator.dart';
import 'package:golds_nuts/core/utils/color_manager.dart';
import 'package:golds_nuts/features/product/domain/entities/product_entity.dart';
import 'package:golds_nuts/features/product/presentation/bloc/product_bloc.dart';
import 'package:golds_nuts/features/product/presentation/bloc/product_event.dart';
import 'package:golds_nuts/features/product/presentation/bloc/product_state.dart';
import 'package:golds_nuts/features/product/presentation/screens/widgets/add_edit_product_dialog.dart';
import 'package:golds_nuts/features/product/presentation/screens/widgets/product_card.dart';

class ManagerScreen extends StatefulWidget {
  const ManagerScreen({super.key});

  @override
  State<ManagerScreen> createState() => _ManagerScreenState();
}

class _ManagerScreenState extends State<ManagerScreen> {
  final TextEditingController _searchController =
  TextEditingController();

  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Add Product Dialog
  void _showAddProductDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AddEditProductDialog(
        onSubmit: (name, price) {
          context.read<ProductBloc>().add(
            AddProductEvent(
              name: name,
              pricePerCarton: price,
            ),
          );
        },
      ),
    );
  }

  // Edit Product Dialog
  void _showEditProductDialog(
      BuildContext context,
      ProductEntity product,
      ) {
    showDialog(
      context: context,
      builder: (_) => AddEditProductDialog(
        isEditing: true,
        initialName: product.name,
        initialPrice: product.pricePerCarton,
        onSubmit: (name, price) {
          context.read<ProductBloc>().add(
            UpdateProductEvent(
              productId: product.id,
              name: name,
              pricePerCarton: price,
            ),
          );
        },
      ),
    );
  }

  // Product Confirmation Dialog
  Future<void> _showProductConfirmation({
    required BuildContext context,
    required ProductEntity product,
    required String title,
    required String message,
    required String confirmText,
    required VoidCallback onConfirm,
    required Color confirmColor,
    IconData icon = Icons.warning_amber_rounded,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: Icon(
          icon,
          color: confirmColor,
          size: 36,
        ),
        title: Text(title),
        content: Text(
          '$message\n\nProduct: ${product.name}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor,
              foregroundColor: Colors.white,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      onConfirm();
    }
  }

  // Activate / Deactivate Product
  void _confirmToggleActive(
      BuildContext context,
      ProductEntity product,
      ) {
    final isActive = product.isActive;

    _showProductConfirmation(
      context: context,
      product: product,
      title: isActive ? 'Deactivate Product?' : 'Activate Product?',
      message: isActive
          ? 'This product will no longer be available to workers.'
          : 'This product will become available to workers again.',
      confirmText: isActive ? 'Deactivate' : 'Activate',
      confirmColor: isActive
          ? ColorManager.error
          : ColorManager.success,
      icon: isActive
          ? Icons.block_outlined
          : Icons.check_circle_outline,
      onConfirm: () {
        context.read<ProductBloc>().add(
          isActive
              ? DeactivateProductEvent(productId: product.id)
              : ActivateProductEvent(productId: product.id),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProductBloc>()
        ..add(GetProductsEvent(activeOnly: false)),
      child: Builder(
        builder: (context) {
          return BlocConsumer<ProductBloc, ProductState>(
            listener: (context, state) {
              if (state is ProductsLoaded) {
                if (state.operationMessage != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.operationMessage!),
                    ),
                  );

                  // Reload products after successful operation.
                  context.read<ProductBloc>().add(
                    GetProductsEvent(activeOnly: false),
                  );
                }

                if (state.operationError != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.operationError!),
                      backgroundColor: ColorManager.error,
                    ),
                  );
                }
              }

              if (state is ProductFailure) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: ColorManager.error,
                  ),
                );
              }
            },
            builder: (context, state) {
              return Scaffold(
                appBar: AppBar(
                  title: const Text('Products Management'),
                ),
                floatingActionButton: FloatingActionButton.extended(
                  onPressed: () => _showAddProductDialog(context),
                  backgroundColor: ColorManager.gold,
                  foregroundColor: ColorManager.textPrimary,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Product'),
                ),
                body: _buildBody(context, state),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, ProductState state) {
    if (state is ProductInitial || state is ProductLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: ColorManager.primary,
        ),
      );
    }

    if (state is ProductFailure) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: ColorManager.error,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(state.message),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () {
                context.read<ProductBloc>().add(
                  GetProductsEvent(activeOnly: false),
                );
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (state is ProductsLoaded) {
      final products = state.products;
      final activeCount = products.where((p) => p.isActive).length;

      final filteredProducts = products.where((product) {
        return product.name.toLowerCase().contains(
          _searchQuery.toLowerCase(),
        );
      }).toList();

      if (products.isEmpty) {
        return Column(
          children: [
            if (state.isProcessing)
              const LinearProgressIndicator(
                color: ColorManager.primary,
              ),
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 64,
                      color: ColorManager.textSecondary,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'No products yet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: ColorManager.textPrimary,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Add your first product to get started',
                      style: TextStyle(
                        color: ColorManager.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }

      return Column(
        children: [
          if (state.isProcessing)
            const LinearProgressIndicator(
              color: ColorManager.primary,
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                final bloc = context.read<ProductBloc>();

                bloc.add(GetProductsEvent(activeOnly: false));

                await bloc.stream.firstWhere(
                      (newState) =>
                  newState is ProductsLoaded ||
                      newState is ProductFailure,
                );
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          ColorManager.primary,
                          ColorManager.primaryLight,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.inventory_2_outlined,
                          color: Colors.white,
                          size: 36,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Total Products',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${products.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text(
                              'Active',
                              style: TextStyle(
                                color: Colors.white70,
                              ),
                            ),
                            Text(
                              '$activeCount',
                              style: const TextStyle(
                                color: ColorManager.goldLight,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.trim();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search products...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                        onPressed: () {
                          _searchController.clear();

                          setState(() {
                            _searchQuery = '';
                          });
                        },
                        icon: const Icon(Icons.close),
                      )
                          : null,
                      filled: true,
                      fillColor: ColorManager.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'All Products',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: ColorManager.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (filteredProducts.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Text('No matching products found'),
                      ),
                    )
                  else
                    ...filteredProducts.map(
                          (product) => ProductCard(
                        product: product,
                        onEdit: () {
                          _showEditProductDialog(context, product);
                        },
                        onToggleActive: () {
                          _confirmToggleActive(context, product);
                        },
                        onDelete: () {
                          // Delete remains disabled until production
                          // record references can be checked safely.
                        },
                      ),
                    ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}

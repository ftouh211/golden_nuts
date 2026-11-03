
import 'package:flutter/material.dart';
import 'package:golds_nuts/features/inventory/domain/entities/inventory_entity.dart';
import 'package:golds_nuts/features/product/domain/entities/product_entity.dart';

class AvailableQuantityCard extends StatelessWidget {
  final List<InventoryEntity> inventory;
  final List<ProductEntity> products;

  // لو عايزين نعرض منتج واحد فقط
  final String? productId;

  // لو عايزين نخصم الكمية المختارة بالفعل في الطلب
  final int alreadySelectedQuantity;

  const AvailableQuantityCard({
    super.key,
    required this.inventory,
    required this.products,
    this.productId,
    this.alreadySelectedQuantity = 0,
  });

  @override
  Widget build(BuildContext context) {
    final selectedInventory = productId == null
        ? inventory
        : inventory.where((item) => item.productId == productId).toList();

    if (selectedInventory.isEmpty) {
      return const Text('No inventory available.');
    }

    return Column(
      children: selectedInventory.map((item) {
        final matchingProducts = products.where(
              (product) => product.id == item.productId,
        );

        final productName = matchingProducts.isNotEmpty
            ? matchingProducts.first.name
            : 'Unknown Product';

        final availableQuantity = item.availableQuantity -
            (item.productId == productId
                ? alreadySelectedQuantity
                : 0);

        return _buildCard(
          productName: productName,
          availableQuantity: availableQuantity,
        );
      }).toList(),
    );
  }

  Widget _buildCard({
    required String productName,
    required int availableQuantity,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Expanded(
          //   child: Text(
          //     productName,
          //     style: const TextStyle(fontWeight: FontWeight.bold),
          //   ),
          // ),
          Text(
            'Available: $availableQuantity cartons',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

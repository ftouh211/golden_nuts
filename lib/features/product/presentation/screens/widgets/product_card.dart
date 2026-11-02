
import 'package:flutter/material.dart';
import 'package:golds_nuts/core/utils/color_manager.dart';
import 'package:golds_nuts/features/product/domain/entities/product_entity.dart';

class ProductCard extends StatelessWidget {
  final ProductEntity product;
  final VoidCallback onEdit;
  final VoidCallback onToggleActive;
  final VoidCallback onDelete;

  const ProductCard({
    super.key,
    required this.product,
    required this.onEdit,
    required this.onToggleActive,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: ColorManager.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ColorManager.border),
        boxShadow: [
          BoxShadow(
            color: ColorManager.primary.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: ColorManager.background,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.inventory_2_outlined,
                    color: ColorManager.primary,
                    size: 27,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: ColorManager.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 5),
                      // Text(
                      //   'Product ID: ${product.id}',
                      //   maxLines: 1,
                      //   overflow: TextOverflow.ellipsis,
                      //   style: const TextStyle(
                      //     fontSize: 11,
                      //     color: ColorManager.textSecondary,
                      //   ),
                      // ),
                    ],
                  ),
                ),

                _buildStatus(),
              ],
            ),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ColorManager.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.sell_outlined,
                    color: ColorManager.gold,
                    size: 21,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Carton Price',
                    style: TextStyle(
                      color: ColorManager.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${product.pricePerCarton.toStringAsFixed(2)} EGP',
                    style: const TextStyle(
                      color: ColorManager.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),

            // Row(
            //   children: [
            //     Expanded(
            //       child: OutlinedButton.icon(
            //         onPressed: onEdit,
            //         icon: const Icon(Icons.edit_outlined, size: 18),
            //         label: const Text('Edit'),
            //         style: OutlinedButton.styleFrom(
            //           foregroundColor: ColorManager.primary,
            //           side: const BorderSide(
            //             color: ColorManager.primary,
            //           ),
            //           shape: RoundedRectangleBorder(
            //             borderRadius: BorderRadius.circular(10),
            //           ),
            //         ),
            //       ),
            //     ),
            //
            //     const SizedBox(width: 10),
            //
            //     Expanded(
            //       child: OutlinedButton.icon(
            //         onPressed: onToggleActive,
            //         icon: Icon(
            //           product.isActive
            //               ? Icons.block_outlined
            //               : Icons.check_circle_outline,
            //           size: 18,
            //         ),
            //         label: Text(
            //           product.isActive ? 'Deactivate' : 'Activate',
            //         ),
            //         style: OutlinedButton.styleFrom(
            //           foregroundColor: product.isActive
            //               ? ColorManager.error
            //               : ColorManager.success,
            //           side: BorderSide(
            //             color: product.isActive
            //                 ? ColorManager.error
            //                 : ColorManager.success,
            //           ),
            //           shape: RoundedRectangleBorder(
            //             borderRadius: BorderRadius.circular(10),
            //           ),
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
            Row(
              children: [
                // Edit Button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Edit'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ColorManager.primary,
                      side: const BorderSide(
                        color: ColorManager.primary,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Activate / Deactivate Button
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onToggleActive,
                    icon: Icon(
                      product.isActive
                          ? Icons.block_outlined
                          : Icons.check_circle_outline,
                      size: 18,
                    ),
                    label: Text(
                      product.isActive ? 'Deactivate' : 'Activate',
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: product.isActive
                          ? ColorManager.error
                          : ColorManager.success,
                      side: BorderSide(
                        color: product.isActive
                            ? ColorManager.error
                            : ColorManager.success,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Delete Button
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                  color: ColorManager.error,
                  tooltip: 'Delete Product',
                  style: IconButton.styleFrom(
                    backgroundColor: ColorManager.error.withValues(alpha: 0.08),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatus() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: product.isActive
            ? ColorManager.success.withValues(alpha: 0.10)
            : ColorManager.error.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        product.isActive ? 'Active' : 'Inactive',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: product.isActive
              ? ColorManager.success
              : ColorManager.error,
        ),
      ),
    );
  }
}

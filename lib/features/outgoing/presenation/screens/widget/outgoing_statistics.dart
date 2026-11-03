import 'package:golds_nuts/features/outgoing/domain/entities/outgoing_entity.dart';

class ProductOutgoingStatistics {
  final String productId;
  final String productName;
  final int quantity;
  final double totalAmount;

  const ProductOutgoingStatistics({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.totalAmount,
  });
}

class OutgoingStatistics {
  final double totalSales;
  final List<ProductOutgoingStatistics> products;
  final List<OutgoingEntity> recentRecords;

  const OutgoingStatistics({
    required this.totalSales,
    required this.products,
    required this.recentRecords,
  });

  factory OutgoingStatistics.fromRecords(List<OutgoingEntity> records) {
    double totalSales = 0;

    final Map<String, ProductOutgoingStatistics> productsMap = {};

    for (final record in records) {
      totalSales += record.totalAmount;

      for (final item in record.items) {
        final existing = productsMap[item.productId];

        if (existing == null) {
          productsMap[item.productId] = ProductOutgoingStatistics(
            productId: item.productId,
            productName: item.productName,
            quantity: item.quantity,
            totalAmount: item.totalAmount,
          );
        } else {
          productsMap[item.productId] = ProductOutgoingStatistics(
            productId: existing.productId,
            productName: existing.productName,
            quantity: existing.quantity + item.quantity,
            totalAmount: existing.totalAmount + item.totalAmount,
          );
        }
      }
    }

    final products = productsMap.values.toList()
      ..sort((a, b) => b.quantity.compareTo(a.quantity));

    final recentRecords = records.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return OutgoingStatistics(
      totalSales: totalSales,
      products: products,
      recentRecords: recentRecords.take(3).toList(),
    );
  }
}

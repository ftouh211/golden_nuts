
class OutgoingItemEntity {
  final String productId;
  final String productName;
  final int quantity;
  final double pricePerCarton;
  final double totalAmount;

  const OutgoingItemEntity({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.pricePerCarton,
    required this.totalAmount,
  });
}
